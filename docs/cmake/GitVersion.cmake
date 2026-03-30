# Semantic versioning from annotated Git tags: vMAJOR.MINOR.PATCH
# - git describe --tags --match "v*" --long  (nearest v* tag on current branch)
# - Optional: working tree dirty detection
#
# Variables (parent scope of caller — set docs/doc/CMakeLists from docs/CMakeLists):
#   LP_PROJECT_VERSION       — "1.3.0" for :revnumber:
#   LP_PROJECT_REVREMARK     — human-readable for :revremark:
#   LP_FULL_VERSION          — 1.3.0+abc1234
#   LP_GIT_DESCRIBE          — raw git describe output
#   LP_DOC_BUILD_ID          — describe + optional " dirty" (for traceability)
#   LP_PROJECT_VERSION_*     — major/minor/patch components

function(get_version_from_git)
  find_package(Git QUIET)
  if(NOT Git_FOUND)
    message(WARNING "Git not found; using CMake fallback version for documentation")
    return()
  endif()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_TOPLEVEL
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE GIT_TOPLEVEL_RESULT
  )
  if(NOT GIT_TOPLEVEL_RESULT EQUAL 0 OR NOT GIT_TOPLEVEL)
    message(WARNING "Could not resolve Git repository root from ${CMAKE_SOURCE_DIR}")
    return()
  endif()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --tags --match "v*" --long
    WORKING_DIRECTORY ${GIT_TOPLEVEL}
    OUTPUT_VARIABLE GIT_DESCRIBE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE GIT_DESCRIBE_RESULT
  )

  if(NOT GIT_DESCRIBE_RESULT EQUAL 0)
    message(WARNING "git describe failed (create an annotated tag like v1.0.0). Using CMake fallback version.")
    return()
  endif()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short=7 HEAD
    WORKING_DIRECTORY ${GIT_TOPLEVEL}
    OUTPUT_VARIABLE GIT_COMMIT_SHORT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  # Non-zero if there are unstaged/staged changes vs HEAD
  execute_process(
    COMMAND ${GIT_EXECUTABLE} diff-index --quiet HEAD --
    WORKING_DIRECTORY ${GIT_TOPLEVEL}
    RESULT_VARIABLE GIT_DIFF_INDEX_RESULT
  )
  set(_DIRTY "")
  if(NOT GIT_DIFF_INDEX_RESULT EQUAL 0)
    set(_DIRTY " — working tree has uncommitted changes")
  endif()

  set(LP_GIT_DESCRIBE "${GIT_DESCRIBE}" PARENT_SCOPE)
  set(LP_DOC_BUILD_ID "${GIT_DESCRIBE}${_DIRTY}" PARENT_SCOPE)

  # Long form: v1.3.0-0-gabc1234 or v1.3.0-5-gdef5678 ; short: v1.3.0
  string(REGEX MATCH "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)(-([0-9]+)-g([a-f0-9]+))?$" _ "${GIT_DESCRIBE}")
  if(NOT CMAKE_MATCH_1)
    message(WARNING "Could not parse semver from git describe: '${GIT_DESCRIBE}'")
    return()
  endif()

  set(_maj ${CMAKE_MATCH_1})
  set(_min ${CMAKE_MATCH_2})
  set(_pat ${CMAKE_MATCH_3})
  set(_after ${CMAKE_MATCH_5})
  set(_ghash ${CMAKE_MATCH_6})

  set(LP_PROJECT_VERSION_MAJOR ${_maj} PARENT_SCOPE)
  set(LP_PROJECT_VERSION_MINOR ${_min} PARENT_SCOPE)
  set(LP_PROJECT_VERSION_PATCH ${_pat} PARENT_SCOPE)
  set(LP_PROJECT_VERSION "${_maj}.${_min}.${_pat}" PARENT_SCOPE)
  set(LP_FULL_VERSION "${_maj}.${_min}.${_pat}+${GIT_COMMIT_SHORT_HASH}" PARENT_SCOPE)

  # :revremark: — short, release-oriented wording
  if(_after STREQUAL "0" OR _after STREQUAL "")
    set(_remark "Release v${_maj}.${_min}.${_pat}")
  else()
    set(_remark "Development build based on v${_maj}.${_min}.${_pat} (+${_after} commits after tag, ${GIT_COMMIT_SHORT_HASH})")
  endif()
  if(NOT _DIRTY STREQUAL "")
    string(APPEND _remark "${_DIRTY}")
  endif()

  set(LP_PROJECT_REVREMARK "${_remark}" PARENT_SCOPE)

  message(STATUS "Documentation version: ${_maj}.${_min}.${_pat} — ${GIT_DESCRIBE}")
endfunction()
