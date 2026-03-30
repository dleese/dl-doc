# Documentation Build Guide

This project uses **CMake** to build documentation in multiple formats (HTML and PDF) for the Logipad project. The documentation is generated from AsciiDoc source files and includes C++ API documentation via Doxygen.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Building the Documentation](#building-the-documentation)
- [Building HTML Documentation](#building-html-documentation)
- [Building PDF Documentation](#building-pdf-documentation)
- [Doxygen Documentation](#doxygen-documentation)
- [Output Locations](#output-locations)
- [Optional Features](#optional-features)
- [Git Workflow](#git-workflow)
- [Git Best Practices](#git-best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **CMake** (version 4.1 or higher)
- **Make** (Unix/Linux/macOS)
- **Asciidoctor** - for converting AsciiDoc to HTML/PDF
  - Install via: `gem install asciidoctor`
- **Asciidoctor-PDF** - for PDF generation
  - Install via: `gem install asciidoctor-pdf`
- **Doxygen** - for C++ API documentation
  - Install via: `brew install doxygen` (macOS) or `apt-get install doxygen` (Linux)
- **Graphviz** (optional, for Doxygen diagrams)
  - Install via: `brew install graphviz` (macOS)

### Font Requirements (for PDF output)

The PDF generation requires the **Inter** font family to be installed:

- **Inter-Regular.otf**
- **Inter-Bold.otf**
- **Inter-Italic.otf**
- **Inter-BoldItalic.otf**

On macOS, place them in `~/Library/Fonts/`. On Linux, use e.g. `~/.local/share/fonts` or `/usr/share/fonts` and ensure the PDF build’s `pdf-fontsdir` (in `docs/doc/CMakeLists.txt`) points to that directory.

Download the Inter font family from [Google Fonts](https://fonts.google.com/specimen/Inter).

### Optional Requirements

- **Git** - for version information (automatically populated in documentation from git tags)

## Project Structure

The documentation is split into **two guides**, each built as HTML and PDF:

| Guide | Role | Chapter files |
| ----- | ---- | --------------- |
| **Logipad Administration Guide** | Deploy, configure, operate (infrastructure, Keycloak, Library/MUI) | `docs/doc/chapters/admin/` |
| **Logipad User Guide** | End users (briefing, login/logout, quick reference) | `docs/doc/chapters/user/` |

Master documents (per-guide title, abstract, chapter includes) are `admin_guide_template.adoc.in` and `user_guide_template.adoc.in`. Shared book settings (author, revision, TOC, images) live in `common/guide_attributes.adoc.in` so both guides stay in sync. Customer-specific URLs are substituted in `chapters/admin/infrastructure.adoc` via CMake from `infrastructure.adoc.in`.

```
dl-doc/
├── docs/                          # Documentation source
│   ├── CMakeLists.txt            # CMake configuration
│   ├── cmake/                     # CMake modules
│   │   ├── Doxygen.cmake         # Doxygen configuration
│   │   ├── GitVersion.cmake      # Git version extraction
│   │   └── ...
│   └── doc/                       # Documentation content
│       ├── admin_guide_template.adoc.in
│       ├── user_guide_template.adoc.in
│       ├── common/
│       │   └── guide_attributes.adoc.in   # shared header for both guides
│       ├── chapters/
│       │   ├── admin/            # Administration Guide chapters
│       │   └── user/             # User Guide chapters
│       ├── images/               # Images and assets
│       └── styles/               # CSS and theme files
└── build/                        # (Generated) Build directory
    └── bin/                      # (Generated) Output files
        ├── admin_guide-<version>.html / .pdf
        └── user_guide-<version>.html / .pdf
```

## Building the Documentation

### 1. Create and Enter Build Directory

```bash
cd /Users/dirk/develop/documentations/dl-doc
mkdir -p build
cd build
```

### 2. Configure with CMake

The default build format is **HTML**:

```bash
cmake ../docs
```

### 3. Build the Documentation

```bash
make doc
```

This will generate **both** guides in the default format. Output files are in `build/doc/bin/`.

### Cleaning the build directory

Use one of these when you want a full reset (for example after large CMake or layout changes). You must run `cmake ../docs` again afterward.

| Method | Command |
| ------ | ------- |
| **CMake target** (from inside `build/`) | `cmake --build . --target clean-build` or `make clean-build` |
| **Shell script** (from repo root; optional path) | `./scripts/clean-build.sh` or `./scripts/clean-build.sh /path/to/your/build` |
| **Manual** | `rm -rf build` (from repo root) then recreate `build/` and reconfigure |

`make clean` only removes build outputs that CMake tracks; it does not delete the whole `build/` tree. `clean-build` removes the entire configured build directory.

## Building HTML Documentation

### Quick Start (Default Format)

```bash
cd build
cmake ../docs
make doc
```

The HTML documentation will be generated at (the `*-<version>*` suffix is SemVer from Git, e.g. `1.3.0`):

- `build/doc/bin/admin_guide-<version>.html` — Administration Guide
- `build/doc/bin/user_guide-<version>.html` — User Guide

Re-run `cmake ../docs` after creating or moving to a new **`v*`** tag so the filename and embedded revision match.

### Open in Browser

After building, open the HTML files in your browser (replace `<version>` with the folder name CMake printed, e.g. `1.3.0`):

```bash
open build/doc/bin/admin_guide-1.3.0.html
open build/doc/bin/user_guide-1.3.0.html
```

### Features

- Beautiful responsive design using doxygen-awesome-css
- Dark mode support with toggle
- Interactive table of contents
- Code snippet copy button
- Responsive sidebar navigation

## Building PDF Documentation

PDF generation uses Asciidoctor-PDF and requires Ruby with the `bigdecimal` gem. On macOS, if `gem install bigdecimal` fails with "The compiler failed to generate an executable file", install the Xcode Command Line Tools first: `xcode-select --install`. Then run `gem install bigdecimal` and rebuild.

### Configure for PDF Output

```bash
cd build
cmake ../docs -DDOC_FORMAT=pdf
make doc
```

The PDF documentation will be generated at:

- `build/doc/bin/admin_guide-<version>.pdf`
- `build/doc/bin/user_guide-<version>.pdf`

### Open the PDF

```bash
open build/doc/bin/admin_guide-1.3.0.pdf
open build/doc/bin/user_guide-1.3.0.pdf
```

### PDF Customization

The PDF styling is controlled by `docs/doc/styles/freebsd-pdf-theme.yml`. It includes:

- Custom title page background image
- Inter font family for professional appearance
- Structured PDF bookmarks and navigation
- Multiple heading levels and formatting

## Doxygen Documentation

The C++ API documentation is generated separately using Doxygen with the awesome-css theme. The Doxygen target is only added when the C++ source directory `docs/src` exists; if your repo does not contain C++ sources, the target will not be available.

### Build Doxygen Documentation

Doxygen documentation is built by default along with the HTML documentation when `docs/src` exists. To build only Doxygen docs:

```bash
cd build
cmake ../docs
make doxygen_docs
```

The Doxygen HTML output will be available at: `build/doxygen/`

### Doxygen Features

- C++ code documentation from source comments
- Beautiful interactive sidebar
- Class hierarchy and relationships
- Full-text search capability
- SVG-based diagrams from Graphviz

## Output Locations

After a successful build, documentation files are located in:

### HTML Output
```
build/doc/bin/admin_guide-<version>.html
build/doc/bin/user_guide-<version>.html
build/doc/bin/images/              # Associated images
build/doc/bin/styles/              # CSS stylesheets
build/doxygen/                      # C++ API documentation (if docs/src exists)
```

### PDF Output
```
build/doc/bin/admin_guide-<version>.pdf
build/doc/bin/user_guide-<version>.pdf
build/doc/bin/images/              # Referenced images
```

## Optional Features

### Enable/Disable Azure Documentation

By default, the "Manage Microsoft Azure AD Users" section in the **Administration Guide** (Keycloak chapter) is **enabled**.

#### Disable Azure Chapter

```bash
cd build
cmake ../docs -DENABLE_AZURE=OFF
make doc
```

#### Re-enable Azure Chapter

```bash
cd build
cmake ../docs -DENABLE_AZURE=ON
make doc
```

### Regenerate MUI Screenshots

Screenshots for the Management User Interface (MUI) can be captured automatically. From the project root:

```bash
cd docs/scripts/mui-screenshots
npm install
```

Set environment variables for MUI login: `MUI_BASE_URL`, `MUI_USERNAME`, `MUI_PASSWORD` (see `docs/scripts/mui-screenshots/README.md`). Then run:

```bash
npm run capture
```

Screenshots are saved to `docs/doc/images/mui/`. The script uses Playwright and Chromium (installed on first `npm install`).

## Troubleshooting

### Issue: "Asciidoctor not found"

**Solution:** Install Asciidoctor:
```bash
gem install asciidoctor asciidoctor-pdf
```

If using a system Ruby that requires `sudo`, consider using a Ruby version manager (rbenv, rvm):
```bash
# Using rbenv
rbenv install 3.2.0
rbenv local 3.2.0
gem install asciidoctor asciidoctor-pdf
```

### Issue: "Doxygen not found"

**Solution:** Install Doxygen:
```bash
# macOS
brew install doxygen

# Linux (Ubuntu/Debian)
sudo apt-get install doxygen

# Linux (Fedora/RHEL)
sudo dnf install doxygen
```

### Issue: PDF build fails with "cannot load such file -- bigdecimal"

**Solution:** Asciidoctor-PDF requires the `bigdecimal` gem. Install it with `gem install bigdecimal` (use the same Ruby that runs `asciidoctor-pdf`, e.g. `/opt/homebrew/opt/ruby/bin/gem install bigdecimal`). If that fails with "The compiler failed to generate an executable file" or "stdio.h file not found", install or reinstall the Xcode Command Line Tools: `xcode-select --install`. Then run the `gem install` again **in your own Terminal** (not inside an IDE), so the compiler and SDK are found. After that, run the PDF build from the project `build/` directory.

### Issue: PDF generation fails with font warnings

**Solution:** Download and install the Inter font family:

1. Download from [Google Fonts](https://fonts.google.com/specimen/Inter)
2. Extract the OTF files
3. Place them in `~/Library/Fonts/` (macOS) or appropriate font directory for your OS
4. Rebuild: `cmake ../docs -DDOC_FORMAT=pdf && make doc`

### Issue: CMake version too old

**Solution:** Update CMake:
```bash
# macOS
brew install cmake

# Or download from https://cmake.org/download/
```

### Issue: Clean rebuild needed

**Solution:** Remove the build directory and configure again. Prefer the [Cleaning the build directory](#cleaning-the-build-directory) options (`clean-build` target or `./scripts/clean-build.sh`), or manually:
```bash
cd /path/to/dl-doc
rm -rf build
mkdir build
cd build
cmake ../docs
make doc
```

### Issue: Images not displaying in PDF

**Solution:** Ensure images are in the correct format and location:
- Images should be in `docs/doc/images/`
- Supported formats: SVG, PNG, JPEG
- Check file paths in `.adoc` source files

## Development Workflow

### Editing Documentation

1. Edit chapter files under `docs/doc/chapters/admin/` or `docs/doc/chapters/user/`, or adjust masters `docs/doc/admin_guide_template.adoc.in` / `user_guide_template.adoc.in`
2. Add/update images in `docs/doc/images/`
3. Rebuild documentation:
   ```bash
   cd build
   make doc
   ```
4. Preview the output in `build/doc/bin/`

### Viewing Changes During Development

For faster iteration, rebuild only without recreating the full build directory:

```bash
cd build
make doc
```

### Version Management

Versioning follows **SemVer** on **annotated `v*`** tags (e.g. `v1.3.0`). The build is the single source of truth: **`cmake ../docs`** runs [`docs/cmake/GitVersion.cmake`](docs/cmake/GitVersion.cmake) from the **repository root** (`git rev-parse --show-toplevel`).

| Item | Behaviour |
| ---- | ----------- |
| **Filenames** | `admin_guide-<version>.html` / `.pdf` use `<version>` = `MAJOR.MINOR.PATCH` parsed from the nearest `v*` tag (`git describe --tags --match "v*" --long`). |
| `:docbuildid:` | Release tag only, e.g. **`v1.4.0`**. No `git describe` suffix or commit hash; optional note if the **working tree is dirty** (`git diff-index`). |
| **Where it appears** | **HTML:** “Release” banner at the top (`docinfo-header.html` + `docinfo=shared`). **PDF:** centered in the **footer** (`freebsd-pdf-theme.yml`). **Title page:** `:revnumber:` (release tag, e.g. `v1.4.0` via `LP_RELEASE_TAG`). |
| **Output files** | `build/doc/bin/admin_guide-<version>.*` and `user_guide-<version>.*`. |

If Git is missing or `describe` fails, CMake fallbacks in [`docs/CMakeLists.txt`](docs/CMakeLists.txt) apply (`LP_PROJECT_VERSION`, `LP_DOC_BUILD_ID`, etc.).

**Workflow:** tag `main` with `v1.3.0`, push the tag, then **`cmake ../docs`** (or a clean configure) and **`make doc`**. See [Git Workflow](#git-workflow) for tag commands.

## Git Workflow

This project uses **GitHub Flow**: `main` is the only long-lived branch and is always releasable. Work is done on short-lived feature branches, then merged into `main`.

### Branch roles

- **`main`** — Production-ready documentation. All merges go here. Release tags (e.g. `v1.1.0`) are created from `main`.
- **`feature/<topic>`** — Created from `main` for a single change (e.g. `feature/library-chapter`, `feature/mui-screenshots-fix`). Merge back into `main` when done, via pull request or direct merge.

### Step-by-step workflow

1. Start from an up-to-date `main`:
   ```bash
   git checkout main
   git pull --rebase origin main
   ```
2. Create a feature branch:
   ```bash
   git checkout -b feature/short-description
   ```
3. Make changes, commit (see [Git Best Practices](#git-best-practices)), push:
   ```bash
   git push -u origin feature/short-description
   ```
4. Merge into `main` (e.g. via pull request on GitHub, or locally):
   ```bash
   git checkout main
   git merge feature/short-description
   git push origin main
   ```
5. To release: create an annotated tag from `main`, then push the tag:
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.0 -m "Release v1.2.0: description of changes"
   git push origin v1.2.0
   ```
   The documentation build will use this tag for version info (see `docs/cmake/GitVersion.cmake`).

## Git Best Practices

- **Commit messages** — Use conventional commits: `type(scope): description`. Examples: `fix(mui-screenshots): do not swallow Keycloak errors`, `docs: add Library chapter`, `feat(scripts): add Keycloak login to capture`. One logical change per commit.
- **Branch naming** — Use `feature/<short-name>`, or if you adopt release/hotfix branches later: `release/<version>`, `hotfix/<short-name>`.
- **Before pushing** — Run `git pull --rebase origin main` (from `main` or before merging) to avoid unnecessary merge commits.
- **No force push** — Do not force-push to `main`; keep history stable for tags and releases.
- **Tags** — Use annotated tags for releases: `git tag -a v1.2.0 -m "Release message"`. Push tags explicitly: `git push origin v1.2.0`.
- **Secrets** — Never commit `.env` or secrets; they are listed in `.gitignore`.

## Environment Information

- **Project Version:** 1.0.0
- **Project Author:** Dirk Leese
- **Customer:** SilkwayWest Airlines
- **Domain:** silkwaywest
- **Platform:** macOS (tested), Linux (compatible), Windows (with appropriate tools)

## Support

For issues or questions about the documentation build process, refer to:

- [CMake Documentation](https://cmake.org/documentation/)
- [Asciidoctor Documentation](https://asciidoctor.org/)
- [Doxygen Documentation](https://www.doxygen.nl/)
