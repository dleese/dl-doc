# Use Project Template File to Create
#


# Get the current project version from the latest Git tag and set it in the build environment
# Description:The function get_version_from_git() defines and sets variables such as PROJECT_VERSION (the current project version string obtained from the latest Git tag)
# and potentially PROJECT_VERSION_MAJOR, PROJECT_VERSION_MINOR, and PROJECT_VERSION_PATCH if the tag follows semantic versioning (e.g., v1.2.3).
# These variables are made available in the CMake environment for use in configuration files and documentation.
get_version_from_git()

configure_file(doc_title_template.adoc.in ${PROJECT_BINARY_DIR}/doc/doc_title.adoc @ONLY)
configure_file(infrastructure.adoc.in ${PROJECT_BINARY_DIR}/doc/infrastructure.adoc @ONLY)

file(COPY styles/ DESTINATION ${PROJECT_BINARY_DIR}/doc/styles/)
file(COPY images/ DESTINATION ${PROJECT_BINARY_DIR}/doc/images/)

# Copy images at build time too so new/changed images are available without re-running cmake
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/images ${CMAKE_CURRENT_BINARY_DIR}/images
  COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
  COMMENT "Copying images to build directory"
)
add_custom_target(copy_doc_images ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/.images_copied)

file(GLOB ASCIIDOC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.adoc")
# Copy .adoc files to build directory
foreach(ADOC_FILE ${ASCIIDOC_FILES})
  get_filename_component(ADOC_FILENAME ${ADOC_FILE} NAME)
  configure_file(${ADOC_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${ADOC_FILENAME} COPYONLY)
endforeach()

# Configure PDF theme with absolute path to background image and Inter font paths
set(PDF_THEME_IN ${CMAKE_CURRENT_SOURCE_DIR}/styles/freebsd-pdf-theme.yml)
set(PDF_THEME_OUT ${PROJECT_BINARY_DIR}/doc/styles/freebsd-pdf-theme.yml)

# Set Inter font paths for font catalog
set(INTER_FONT_REGULAR "$ENV{HOME}/Library/Fonts/Inter-Regular.otf")
set(INTER_FONT_BOLD "$ENV{HOME}/Library/Fonts/Inter-Bold.otf")
set(INTER_FONT_ITALIC "$ENV{HOME}/Library/Fonts/Inter-Italic.otf")
set(INTER_FONT_BOLD_ITALIC "$ENV{HOME}/Library/Fonts/Inter-BoldItalic.otf")

# Set title page background image path (absolute path in build directory)
set(TITLE_PAGE_BG_IMAGE "${PROJECT_BINARY_DIR}/doc/images/dd/dd_title_page.svg")

configure_file(${PDF_THEME_IN} ${PDF_THEME_OUT} @ONLY)

# Set output directory to bin subdirectory
set(BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/bin)
file(MAKE_DIRECTORY ${BIN_DIR})

# Common asciidoctor attributes
set(ASCIIDOCTOR_ATTRS
  -a icons=font 
  -a experimental
  -a xrefstyle=short
  -a doctype=book
  -a toc=left
  -a toclevels=3
  -a sectnums
  -a sectnumlevels=4
  -a imagesdir=images/
)
if(ENABLE_AZURE)
  list(APPEND ASCIIDOCTOR_ATTRS -a enable-azure)
endif()

if(DOC_FORMAT STREQUAL "html")
  # HTML output is in BIN_DIR (doc/bin/); img src="images/..." is relative to that, so copy images there
  add_custom_command(
    OUTPUT ${BIN_DIR}/doc_title.html
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_DIR}/images
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/images ${BIN_DIR}/images
    COMMAND asciidoctor ${CMAKE_CURRENT_BINARY_DIR}/doc_title.adoc 
      -a stylesheet=styles/freebsd-theme.css
      ${ASCIIDOCTOR_ATTRS}
      -o ${BIN_DIR}/doc_title.html
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/doc_title.adoc ${ASCIIDOC_FILES} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating HTML documentation with Asciidoctor"
  )
  add_custom_target(doc ALL DEPENDS ${BIN_DIR}/doc_title.html)
  add_dependencies(doc copy_doc_images)
  
elseif(DOC_FORMAT STREQUAL "pdf")
  # PDF generation - use same dependencies as HTML so any chapter change triggers rebuild
  set(PDF_DEPENDENCIES ${CMAKE_CURRENT_BINARY_DIR}/doc_title.adoc ${CMAKE_CURRENT_BINARY_DIR}/infrastructure.adoc ${PDF_THEME_OUT} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied)
  foreach(ADOC_FILE ${ASCIIDOC_FILES})
    get_filename_component(ADOC_FILENAME ${ADOC_FILE} NAME)
    list(APPEND PDF_DEPENDENCIES ${CMAKE_CURRENT_BINARY_DIR}/${ADOC_FILENAME})
  endforeach()
  
  # Configure font directory for Inter font
  set(FONTS_DIR "$ENV{HOME}/Library/Fonts")
  
  add_custom_command(
    OUTPUT ${BIN_DIR}/doc_title.pdf
    COMMAND asciidoctor-pdf ${CMAKE_CURRENT_BINARY_DIR}/doc_title.adoc 
      -a pdf-theme=styles/freebsd-pdf-theme.yml
      -a pdf-fontsdir=${FONTS_DIR}
      # -a title-page-background-image=${CMAKE_CURRENT_BINARY_DIR}/images/dd/dd_title_page.svg
      ${ASCIIDOCTOR_ATTRS}
      -o ${BIN_DIR}/doc_title.pdf
    DEPENDS ${PDF_DEPENDENCIES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating PDF documentation with Asciidoctor-PDF"
  )
  add_custom_target(doc ALL DEPENDS ${BIN_DIR}/doc_title.pdf)
  add_dependencies(doc copy_doc_images)
  
else()
  message(FATAL_ERROR "DOC_FORMAT must be either 'html' or 'pdf', got '${DOC_FORMAT}'")
endif()