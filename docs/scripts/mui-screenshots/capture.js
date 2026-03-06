#!/usr/bin/env node
/**
 * Logipad MUI screenshot capture for documentation.
 * Logs in, navigates to each configured page, and saves screenshots at a fixed viewport size.
 *
 * Requires: MUI_BASE_URL, MUI_USERNAME, MUI_PASSWORD (environment variables or .env)
 * Optional: MUI_CONFIG path to custom config JSON
 *
 * Output: screenshots saved to docs/doc/images/mui/
 */

require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');

const DEFAULT_CONFIG_PATH = path.join(__dirname, 'mui-screenshots.config.json');
const DEFAULT_OUTPUT_DIR = path.join(__dirname, '..', '..', 'doc', 'images', 'mui');

async function loadConfig() {
  const configPath = process.env.MUI_CONFIG || DEFAULT_CONFIG_PATH;
  if (!fs.existsSync(configPath)) {
    throw new Error(`Config not found: ${configPath}`);
  }
  const raw = fs.readFileSync(configPath, 'utf8');
  return JSON.parse(raw);
}

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required env: ${name}. Set it or use a .env file.`);
  }
  return value;
}

async function main() {
  const configPath = process.env.MUI_CONFIG || DEFAULT_CONFIG_PATH;
  const config = await loadConfig();
  const baseUrl = process.env.MUI_BASE_URL || config.baseUrl;
  const username = requireEnv('MUI_USERNAME');
  const password = requireEnv('MUI_PASSWORD');

  if (!baseUrl) {
    throw new Error('Set MUI_BASE_URL or baseUrl in config.');
  }

  const outputDir = path.resolve(__dirname, path.join('..', '..', 'doc', 'images', 'mui'));
  const viewport = config.viewport || { width: 1280, height: 720 };
  const login = config.login || {};
  const captures = config.captures || [];

  if (captures.length === 0) {
    console.log('No captures defined in config. Add entries to "captures" in', configPath);
    process.exit(0);
  }

  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: viewport.width, height: viewport.height },
    ignoreHTTPSErrors: true,
  });

  const page = await context.newPage();

  try {
    const loginUrl = new URL(login.urlPath || '/login', baseUrl).toString();
    const useKeycloak = login.keycloak === true;

    console.log('Navigating to', loginUrl, useKeycloak ? '(Keycloak login)' : '');
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });

    if (useKeycloak) {
      // MUI redirects to Keycloak: wait for Keycloak login form, then fill and submit
      const userSel = login.usernameSelector || '#username';
      const passSel = login.passwordSelector || '#password';
      const submitSel = login.submitSelector || '#kc-login';
      const keycloakWaitMs = login.keycloakFormWaitMs ?? 15000;

      await page.waitForSelector(userSel, { state: 'visible', timeout: keycloakWaitMs });
      await page.locator(userSel).fill(username);
      await page.locator(passSel).fill(password);
      await page.locator(submitSel).click();

      // Wait for redirect back to MUI (URL contains base host)
      const muiHost = new URL(baseUrl).host;
      await page.waitForURL((u) => u.host === muiHost, { timeout: 20000 }).catch(() => {});
      const waitMs = login.waitAfterLoginMs ?? 3000;
      await page.waitForTimeout(waitMs);
    } else {
      const userSel = login.usernameSelector || 'input[name=username], #username';
      const passSel = login.passwordSelector || 'input[name=password], #password';
      const submitSel = login.submitSelector || 'button[type=submit]';

      await page.locator(userSel).fill(username);
      await page.locator(passSel).fill(password);
      await page.locator(submitSel).click();

      const waitMs = login.waitAfterLoginMs ?? 2000;
      await page.waitForTimeout(waitMs);
    }

    for (const cap of captures) {
      const url = new URL(cap.path, baseUrl).toString();
      const filename = cap.filename || `${cap.name || cap.path.replace(/\//g, '-')}.png`;
      const filepath = path.join(outputDir, filename);

      console.log('Capture:', cap.name || cap.path, '->', filename);
      await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

      // Optional: wait after page load (e.g. for SPAs or slow content)
      const waitAfterLoadMs = cap.waitAfterLoadMs ?? 500;
      await page.waitForTimeout(waitAfterLoadMs);

      // Optional: click icon/button to open another interface (e.g. user input mask, modal)
      if (cap.clickSelector) {
        const waitAfterClickMs = cap.waitAfterClickMs ?? 1000;
        await page.locator(cap.clickSelector).click({ timeout: 10000 });
        await page.waitForTimeout(waitAfterClickMs);
      }

      await page.screenshot({ path: filepath, fullPage: false });
    }
  } finally {
    await browser.close();
  }

  console.log('Screenshots saved to', outputDir);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
