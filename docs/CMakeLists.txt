cmake_minimum_required(VERSION 4.1)
project(dl-docs VERSION 1.0 DESCRIPTION "Logipad initial Setup" LANGUAGES CXX)
string(TIMESTAMP LP_CURRENT_TIME_UTC "%Y-%m-%d %H:%M:%S" UTC)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
# Optional: include(cpp-httplib) and CppHttpLib() when adding C++ tooling that needs httplib.

# =========================================================
# Add Project specific variables here
# =========================================================
#
# Version Information
# Author
# Customer Company Name
# Customer Domain

# Fallback when Git is missing or no v* tag matches; GitVersion overwrites when available.
set(LP_PROJECT_VERSION "1.0.0")
set(LP_PROJECT_REVREMARK "local build — create annotated tag vMAJOR.MINOR.PATCH on main")
set(LP_DOC_BUILD_ID "unknown")
set(LP_PROJECT_AUTHOR "Dirk Leese")
set(LP_CUSTOMER_COMPANY_NAME "SilkwayWest Airlines")
set(LP_CUSTOMER_DOMAIN "silkwaywest")

# Document output format: "html" or "pdf". Override with -DDOC_FORMAT=pdf when configuring.
set(DOC_FORMAT "html" CACHE STRING "Document format: html or pdf")
set_property(CACHE DOC_FORMAT PROPERTY STRINGS "html" "pdf")

# Enable/disable optional chapters. Override with -DENABLE_AZURE=OFF when configuring.
option(ENABLE_AZURE "Enable 'Manage Microsoft Azure AD Users' chapter in documentation" ON)

include(GitVersion)
# Version from Git before doc/ configures (single source of truth for tags v*)
get_version_from_git()

add_subdirectory(doc)

# Remove the entire CMake build directory (same as deleting the build folder).
# Run from the build directory: cmake --build . --target clean-build
# Or from repo root: ./scripts/clean-build.sh
# After this, you must run cmake again to configure a fresh build.
get_filename_component(DL_DOC_REPO_ROOT "${CMAKE_SOURCE_DIR}/.." ABSOLUTE)
add_custom_target(clean-build
  COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}"
  WORKING_DIRECTORY "${DL_DOC_REPO_ROOT}"
  COMMENT "Removing CMake build directory: ${CMAKE_BINARY_DIR}"
  VERBATIM
)

# Doxygen target is only added when C++ source dir docs/src exists (see README).
if(EXISTS "${CMAKE_SOURCE_DIR}/src")
  include(Doxygen)
  Doxygen(src doxygen)
endif()