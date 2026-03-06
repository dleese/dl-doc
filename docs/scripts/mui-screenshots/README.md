# Logipad MUI Screenshot Automation

Captures screenshots from the Logipad Management User Interface (MUI) at a **fixed viewport size** for consistent documentation. Screenshots are saved to `docs/doc/images/mui/`.

## Prerequisites

- Node.js 18+
- Logipad MUI URL and credentials

## Setup

```bash
cd docs/scripts/mui-screenshots
npm install
```

This installs Playwright and Chromium. On first run, `npm run capture` will use the installed browser.

## Configuration

1. **Environment variables** (required for login):

   - `MUI_BASE_URL` – base URL of the MUI (e.g. `https://mui.your-domain.com`)
   - `MUI_USERNAME` – login username
   - `MUI_PASSWORD` – login password

   Optional:

   - `MUI_CONFIG` – path to a custom config file (default: `mui-screenshots.config.json`)

2. **Config file** (`mui-screenshots.config.json`):

   - `viewport` – `{ "width": 1280, "height": 720 }` – same size for all screenshots
   - `baseUrl` – fallback if `MUI_BASE_URL` is not set
   - `login` – selectors and options for the login form (see *Keycloak login* below)
   - `captures` – list of **MUI** pages to capture after login (see below)

Add or edit entries in `captures` to add new screenshots. Each capture can optionally **click an icon or button** before taking the screenshot (e.g. to open a modal or user input mask).

| Field | Required | Description |
|-------|----------|--------------|
| `name` | no | Label for logging |
| `path` | yes | MUI URL path (e.g. `/users`) |
| `filename` | yes | Output PNG name in `images/mui/` |
| `waitAfterLoadMs` | no | Ms to wait after page load before click/screenshot (default: 500) |
| `clickSelector` | no | CSS/Playwright selector to click before screenshot (opens dialog, form, etc.) |
| `waitAfterClickMs` | no | Ms to wait after click before screenshot (default: 1000) |

Example – page only:

```json
{ "name": "users", "path": "/users", "filename": "mui_users.png" }
```

Example – click „User anlegen“ then capture the input mask:

```json
{
  "name": "user-input-mask",
  "path": "/users",
  "clickSelector": "button:has-text('Add User'), [aria-label='Add user'], .add-user-btn",
  "waitAfterClickMs": 1500,
  "filename": "mui_user_input_mask.png"
}
```

Replace `clickSelector` with the selector that matches your MUI (e.g. icon, button text, `aria-label`, or class). Playwright supports `:has-text('…')` for button/link text.

## Run

```bash
export MUI_BASE_URL="https://mui.your-domain.com"
export MUI_USERNAME="your-user"
export MUI_PASSWORD="your-password"
npm run capture
```

Or copy `.env.example` to `.env`, fill in the values, and run `npm run capture` (the script loads `.env` automatically).

Screenshots are written to **docs/doc/images/mui/** with the configured filenames.

## Keycloak login

When the MUI uses Keycloak for authentication, set `login.keycloak: true` in the config. The script will:

1. Open the MUI `baseUrl` (and `login.urlPath`, e.g. `/` or `/login`).
2. Follow the redirect to the Keycloak login page.
3. Wait for the Keycloak login form and fill username/password (from `MUI_USERNAME` / `MUI_PASSWORD`).
4. Submit and wait for redirect back to the MUI.
5. Navigate to each URL in `captures` on the **MUI** and take a screenshot.

Use Keycloak’s default selectors (realm login page) or override them in config:

| Option               | Default      | Description                    |
|----------------------|-------------|--------------------------------|
| `usernameSelector`   | `#username` | Keycloak username field       |
| `passwordSelector`   | `#password` | Keycloak password field       |
| `submitSelector`     | `#kc-login` | Keycloak login button         |
| `waitAfterLoginMs`   | `3000`      | Delay after submit before next step |
| `keycloakFormWaitMs` | `15000`     | Max wait for Keycloak form after opening MUI (redirect) |

All entries in `captures` are **MUI paths** (e.g. `/users`, `/Roles`). They are opened after successful login; no Keycloak URLs go in `captures`.

## Use in documentation

In AsciiDoc, reference MUI screenshots with `imagesdir` set to `images/` (as in this project):

```asciidoc
image::mui/mui-dashboard.png[MUI Dashboard,1280,720]
```

Width/height in the macro can match the capture viewport (e.g. 1280x720) for consistent display.
