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

```
dl-doc/
├── docs/                          # Documentation source
│   ├── CMakeLists.txt            # CMake configuration
│   ├── cmake/                     # CMake modules
│   │   ├── Doxygen.cmake         # Doxygen configuration
│   │   ├── GitVersion.cmake      # Git version extraction
│   │   └── ...
│   └── doc/                       # Documentation content
│       ├── *.adoc                # AsciiDoc source files
│       ├── images/               # Images and assets
│       └── styles/               # CSS and theme files
└── build/                        # (Generated) Build directory
    └── bin/                      # (Generated) Output files
        ├── doc_title.html        # HTML documentation
        └── doc_title.pdf         # PDF documentation
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

This will generate the documentation in the default format and the output will be available in `build/doc/bin/`.

## Building HTML Documentation

### Quick Start (Default Format)

```bash
cd build
cmake ../docs
make doc
```

The HTML documentation will be generated at: `build/doc/bin/doc_title.html`

### Open in Browser

After building, open the HTML file in your browser:

```bash
open build/doc/bin/doc_title.html
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

The PDF documentation will be generated at: `build/doc/bin/doc_title.pdf`

### Open the PDF

```bash
open build/doc/bin/doc_title.pdf
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
build/doc/bin/doc_title.html
build/doc/bin/images/              # Associated images
build/doc/bin/styles/              # CSS stylesheets
build/doxygen/                      # C++ API documentation
```

### PDF Output
```
build/doc/bin/doc_title.pdf
build/doc/bin/images/              # Referenced images
```

## Optional Features

### Enable/Disable Azure Documentation

By default, the "Manage Microsoft Azure AD Users" chapter is **enabled**.

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

### Issue: PDF build fails with "cannot load such file -- bigdecimal/logger/ostruct"

**Root cause:** Ruby 4.0 removed several previously bundled standard library items (`bigdecimal`, `logger`, `ostruct`, `csv`, `base64`, `mutex_m`, `drb`, `nkf`) from the default gems. When Homebrew upgrades Ruby to 4.0+, the `asciidoctor` formula's isolated gem environment (in `libexec/`) stops working because these gems are no longer available. Running `brew reinstall asciidoctor` restores the formula but does not add the missing gems — they must be installed manually into the formula's gem environment.

**Solution:** Install the missing gems directly into the Homebrew formula's gem path, with `SDKROOT` set so the C compiler can find the macOS SDK headers:

```bash
SDKROOT=$(xcrun --sdk macosx --show-sdk-path) \
GEM_HOME=/opt/homebrew/Cellar/asciidoctor/2.0.26/libexec \
/opt/homebrew/opt/ruby/bin/gem install \
  bigdecimal logger ostruct csv base64 mutex_m drb nkf
```

> **Note:** Adjust the path `asciidoctor/2.0.26` to match the installed version (`brew info asciidoctor` shows the path). This step must be repeated after any `brew reinstall asciidoctor`.

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

**Solution:** Remove the build directory and rebuild from scratch:
```bash
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

1. Edit AsciiDoc files in `docs/doc/*.adoc`
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

The project version is automatically extracted from Git tags. See [Git Workflow](#git-workflow) for how to create and push release tags.

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
