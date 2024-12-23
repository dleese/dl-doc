cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(dl-doc)

#Asciidoctor_EXECUTABLE
find_program ( ASCIIDOCTOR asciidoctor REQUIRED)
find_program ( GIT git REQUIRED )

# Retrieve the version number from Git
execute_process(
    COMMAND ${GIT} describe --tags
    #COMMAND ${GIT} rev-parse HEAD
    OUTPUT_VARIABLE GIT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Define the input template and output file
set(TEMPLATE_FILE ${CMAKE_SOURCE_DIR}/version_template.adoc)
set(OUTPUT_FILE ${CMAKE_SOURCE_DIR}/docs/version.adoc)

message(STATUS ${CMAKE_BINARY_DIR})

# Configure the file by replacing @VERSION@ with the actual version number
configure_file(${TEMPLATE_FILE} ${OUTPUT_FILE} @ONLY)

## Build HTML File and Open it in the current Browser
execute_Process(
    COMMAND ${ASCIIDOCTOR} ${CMAKE_SOURCE_DIR}/docs/index.adoc
    COMMAND open ${CMAKE_SOURCE_DIR}/docs/index.html
)
