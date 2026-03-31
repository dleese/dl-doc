# Use Project Template File to Create
#


# Version variables come from parent docs/CMakeLists.txt (get_version_from_git).

# Shared book attributes (author, TOC, images, :docbuildid: release tag) — single place for both guides
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/common)
configure_file(common/guide_attributes.adoc.in ${CMAKE_CURRENT_BINARY_DIR}/common/guide_attributes.adoc @ONLY)

# HTML: top banner with release tag from :docbuildid: (Asciidoctor docinfo=shared)
configure_file(docinfo-header.html.in ${CMAKE_CURRENT_BINARY_DIR}/docinfo-header.html @ONLY)

configure_file(admin_guide_template.adoc.in ${PROJECT_BINARY_DIR}/doc/admin_guide.adoc @ONLY)
configure_file(user_guide_template.adoc.in ${PROJECT_BINARY_DIR}/doc/user_guide.adoc @ONLY)
configure_file(chapters/admin/infrastructure.adoc.in ${PROJECT_BINARY_DIR}/doc/chapters/admin/infrastructure.adoc @ONLY)

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

# Chapter .adoc files (exclude .in; infrastructure is generated above)
file(GLOB_RECURSE CHAPTER_ADOC_FILES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/chapters/**/*.adoc")
foreach(CHAPTER_FILE ${CHAPTER_ADOC_FILES})
  file(RELATIVE_PATH CHAPTER_REL ${CMAKE_CURRENT_SOURCE_DIR} ${CHAPTER_FILE})
  configure_file(${CHAPTER_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${CHAPTER_REL} COPYONLY)
endforeach()

set(BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/bin)
file(MAKE_DIRECTORY ${BIN_DIR})

# Versioned output names (SemVer from Git; matches LP_PROJECT_VERSION in filenames)
set(LP_DOC_ARTIFACT_SUFFIX "${LP_PROJECT_VERSION}")
if(LP_DOC_ARTIFACT_SUFFIX STREQUAL "")
  set(LP_DOC_ARTIFACT_SUFFIX "local")
endif()
set(ADMIN_GUIDE_HTML "${BIN_DIR}/admin_guide-${LP_DOC_ARTIFACT_SUFFIX}.html")
set(USER_GUIDE_HTML "${BIN_DIR}/user_guide-${LP_DOC_ARTIFACT_SUFFIX}.html")
set(ADMIN_GUIDE_PDF "${BIN_DIR}/admin_guide-${LP_DOC_ARTIFACT_SUFFIX}.pdf")
set(USER_GUIDE_PDF "${BIN_DIR}/user_guide-${LP_DOC_ARTIFACT_SUFFIX}.pdf")

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
  -a docinfo=shared
)
if(ENABLE_AZURE)
  list(APPEND ASCIIDOCTOR_ATTRS -a enable-azure)
endif()

# All sources that affect either guide build
set(GUIDE_MASTER_SOURCES
  ${CMAKE_CURRENT_BINARY_DIR}/admin_guide.adoc
  ${CMAKE_CURRENT_BINARY_DIR}/user_guide.adoc
  ${CMAKE_CURRENT_BINARY_DIR}/common/guide_attributes.adoc
  ${CMAKE_CURRENT_BINARY_DIR}/chapters/admin/infrastructure.adoc
)
set(GUIDE_CHAPTER_SOURCES ${CHAPTER_ADOC_FILES})
list(APPEND GUIDE_CHAPTER_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/chapters/admin/infrastructure.adoc.in
  ${CMAKE_CURRENT_SOURCE_DIR}/common/guide_attributes.adoc.in
  ${CMAKE_CURRENT_SOURCE_DIR}/docinfo-header.html.in
)

if(DOC_FORMAT STREQUAL "html")
  add_custom_command(
    OUTPUT ${ADMIN_GUIDE_HTML}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_DIR}/images
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/images ${BIN_DIR}/images
    COMMAND asciidoctor ${CMAKE_CURRENT_BINARY_DIR}/admin_guide.adoc 
      -a stylesheet=styles/freebsd-theme.css
      ${ASCIIDOCTOR_ATTRS}
      -a imagesdir=images/mui
      -o ${ADMIN_GUIDE_HTML}
    DEPENDS ${GUIDE_MASTER_SOURCES} ${GUIDE_CHAPTER_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
      ${CMAKE_CURRENT_BINARY_DIR}/docinfo-header.html
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating Administration Guide (HTML)"
  )
  add_custom_command(
    OUTPUT ${USER_GUIDE_HTML}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_DIR}/images
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/images ${BIN_DIR}/images
    COMMAND asciidoctor ${CMAKE_CURRENT_BINARY_DIR}/user_guide.adoc 
      -a stylesheet=styles/freebsd-theme.css
      ${ASCIIDOCTOR_ATTRS}
      -a imagesdir=images/ios
      -o ${USER_GUIDE_HTML}
    DEPENDS ${GUIDE_MASTER_SOURCES} ${GUIDE_CHAPTER_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
      ${CMAKE_CURRENT_BINARY_DIR}/docinfo-header.html
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating User Guide (HTML)"
  )
  add_custom_target(doc ALL DEPENDS ${ADMIN_GUIDE_HTML} ${USER_GUIDE_HTML})
  add_dependencies(doc copy_doc_images)
  
elseif(DOC_FORMAT STREQUAL "pdf")
  set(FONTS_DIR "$ENV{HOME}/Library/Fonts")

  add_custom_command(
    OUTPUT ${ADMIN_GUIDE_PDF}
    COMMAND asciidoctor-pdf ${CMAKE_CURRENT_BINARY_DIR}/admin_guide.adoc 
      -a pdf-theme=styles/freebsd-pdf-theme.yml
      -a pdf-fontsdir=${FONTS_DIR}
      ${ASCIIDOCTOR_ATTRS}
      -a imagesdir=images/mui
      -o ${ADMIN_GUIDE_PDF}
    DEPENDS ${GUIDE_MASTER_SOURCES} ${PDF_THEME_OUT} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/admin/contacts.adoc
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/admin/keycloak.adoc
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/admin/infrastructure.adoc
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/admin/library.adoc
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating Administration Guide (PDF)"
  )
  add_custom_command(
    OUTPUT ${USER_GUIDE_PDF}
    COMMAND asciidoctor-pdf ${CMAKE_CURRENT_BINARY_DIR}/user_guide.adoc 
      -a pdf-theme=styles/freebsd-pdf-theme.yml
      -a pdf-fontsdir=${FONTS_DIR}
      ${ASCIIDOCTOR_ATTRS}
      -a imagesdir=images/ios
      -o ${USER_GUIDE_PDF}
    DEPENDS ${GUIDE_MASTER_SOURCES} ${PDF_THEME_OUT} ${CMAKE_CURRENT_BINARY_DIR}/.images_copied
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/user/briefing.adoc
      ${CMAKE_CURRENT_BINARY_DIR}/chapters/user/quick_reference_guide.adoc
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating User Guide (PDF)"
  )
  add_custom_target(doc ALL DEPENDS ${ADMIN_GUIDE_PDF} ${USER_GUIDE_PDF})
  add_dependencies(doc copy_doc_images)
  
else()
  message(FATAL_ERROR "DOC_FORMAT must be either 'html' or 'pdf', got '${DOC_FORMAT}'")
endif()
