cmake_minimum_required(VERSION 4.1)
project(dl-docs VERSION 1.0 DESCRIPTION "Logipad initial Setup" LANGUAGES CXX)
string(TIMESTAMP LP_CURRENT_TIME_UTC "%Y-%m-%d %H:%M:%S" UTC)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# =========================================================
# Add Project specific variables here
# =========================================================
#
# Version Information
# Author
# Customer Company Name
# Customer Domain

set(LP_PROJECT_VERSION "1.0.0")
set(LP_PROJECT_AUTHOR "Dirk Leese")
set(LP_CUSTOMER_COMPANY_NAME "SilkwayWest Airlines")
set(LP_CUSTOMER_DOMAIN "silkwaywest")

# Document output format: "html" or "pdf". Override with -DDOC_FORMAT=pdf when configuring.
set(DOC_FORMAT "html" CACHE STRING "Document format: html or pdf")
set_property(CACHE DOC_FORMAT PROPERTY STRINGS "html" "pdf")

# Enable/disable optional chapters. Override with -DENABLE_AZURE=OFF when configuring.
option(ENABLE_AZURE "Enable 'Manage Microsoft Azure AD Users' chapter in documentation" ON)

include(GitVersion)
add_subdirectory(doc)

include(Doxygen)
Doxygen(src doxygen)