# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CMake-based documentation build system that generates HTML and PDF guides (Admin Guide + User Guide) for the **Logipad** EFB platform. Customer: SilkwayWest Airlines (`silkwaywest` domain).

## Build Commands

All builds run from a `build/` directory:

```bash
mkdir -p build && cd build

# Configure (HTML, default)
cmake ../docs

# Configure (PDF)
cmake ../docs -DDOC_FORMAT=pdf

# Configure without Azure AD section
cmake ../docs -DENABLE_AZURE=OFF

# Build documentation
make doc

# Full clean rebuild
cd .. && rm -rf build/
```

Output lands in `build/doc/bin/` as `admin_guide-<VERSION>.html/.pdf` and `user_guide-<VERSION>.html/.pdf`.

## Architecture

**Version source of truth:** Annotated Git tags (`v1.5.0`, etc.) — `docs/cmake/GitVersion.cmake` extracts SemVer from `git describe` and injects it into all filenames and title pages via CMake variables (`LP_PROJECT_VERSION`, `LP_DOC_BUILD_ID`).

**Template pipeline:**
1. `docs/doc/common/guide_attributes.adoc.in` — shared attributes (author, TOC depth, image paths, release tag) for both guides
2. `docs/doc/admin_guide_template.adoc.in` / `user_guide_template.adoc.in` — master templates that `include::` chapters
3. Chapter files in `docs/doc/chapters/admin/` and `docs/doc/chapters/user/` — actual content
4. `.adoc.in` files with `@VARIABLE@` placeholders are processed by CMake's `configure_file()` before Asciidoctor renders them

**Customer substitution:** `docs/doc/chapters/admin/infrastructure.adoc.in` contains `@LP_CUSTOMER_DOMAIN@`, `@LP_CUSTOMER_COMPANY_NAME@`, etc. — all substituted at CMake configure time from `docs/CMakeLists.txt`.

**Feature flag:** `-DENABLE_AZURE=ON/OFF` (default ON) controls whether the "Manage Microsoft Azure AD Users" section appears in the Keycloak/IAM chapter.

## MUI Screenshot Automation

Node.js + Playwright tool to capture Management UI screenshots:

```bash
cd docs/scripts/mui-screenshots
npm install          # installs Playwright + Chromium
cp .env.example .env # set MUI_BASE_URL, MUI_USERNAME, MUI_PASSWORD
npm run capture      # outputs to docs/doc/images/mui/
```

## Release Process

1. Merge changes to `main`
2. Create annotated tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z: summary"`
3. Push: `git push origin main && git push origin vX.Y.Z`
4. Optional GitHub release: `gh release create vX.Y.Z --title "vX.Y.Z — title" --notes "..."`

Versioning: patch = doc fixes, minor = new sections/chapters, major = structural changes.

## Known Issues

### PDF build fails: "cannot load such file -- bigdecimal" (and others)

**Root cause:** Ruby 4.0 removed `bigdecimal`, `logger`, `ostruct`, `csv`, `base64`, `mutex_m`, `drb`, and `nkf` from the default stdlib. The Homebrew `asciidoctor` formula runs inside its own isolated gem environment (`libexec/`) and does not automatically pick up these gems when Ruby is upgraded. `brew reinstall asciidoctor` restores the formula but does not fix this — the gems must be added manually.

**Fix** (re-run after any `brew reinstall asciidoctor`):

```bash
SDKROOT=$(xcrun --sdk macosx --show-sdk-path) \
GEM_HOME=/opt/homebrew/Cellar/asciidoctor/2.0.26/libexec \
/opt/homebrew/opt/ruby/bin/gem install \
  bigdecimal logger ostruct csv base64 mutex_m drb nkf
```

Adjust the version in the path to match `brew info asciidoctor`. `SDKROOT` is required because without it the C compiler cannot find `stdio.h` on macOS, causing native gem extensions to fail to compile.

## Commit Convention

Use conventional commits: `type(scope): description`
Examples: `docs: add Library chapter`, `fix(mui-screenshots): update selector`, `chore: update dependencies`
