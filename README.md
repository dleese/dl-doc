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

On macOS, these should be placed in: `~/Library/Fonts/`

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

The C++ API documentation is generated separately using Doxygen with the awesome-css theme.

### Build Doxygen Documentation

Doxygen documentation is built by default along with the HTML documentation. To build only Doxygen docs:

```bash
cd build
cmake .. /docs
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
cmake .. /docs -DENABLE_AZURE=OFF
make doc
```

#### Re-enable Azure Chapter

```bash
cd build
cmake .. /docs -DENABLE_AZURE=ON
make doc
```

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

The project version is automatically extracted from Git tags. When you tag a release:

```bash
git tag v1.0.0
```

The version will be automatically included in the generated documentation.

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
