# FindPCRE2.cmake
#
# CMake find module for Perl Compatible Regular Expressions.
#
# In particular, it looks for the more recent PCRE2, not the EOL PCRE library.
#
# See https://www.pcre.org/ for more details.
#
# This find module first tries to use the upstream PCRE2 CMake config script
# that is bundled with more recent PCRE2 versions since 10.38.
#
# If config search fails, the original find logic will be used, and if
# successful will define the imported PCRE2::8BIT library target. You will need
# to specify 8BIT in the find_package COMPONENTS argument, e.g.
#
#   find_package(PCRE2 10.39 REQUIRED COMPONENTS 8BIT)
#   target_link_libraries(my_target PRIVATE PCRE2::8BIT)
#
# To match the behavior of the upstream PCRE2 CMake config script, the
# PCRE2_USE_STATIC_LIBS CMake variable can be set to ON to explicitly look
# for the PCRE2::8BIT static library instead of the shared library.
#
# When search succeeds, PCRE2_FOUND is true, and these variables are set:
#
#   PCRE2_LIBRARIES       PCRE2 library files
#   PCRE2_INCLUDE_DIRS    PCRE2 include directories
#

include(FindPackageHandleStandardArgs)

# PCRE2_USE_STATIC_LIBS can be used to control static/shared PCRE2 search
if(PCRE2_USE_STATIC_LIBS)
  message(STATUS "PCRE2 libs: Static")
else()
  message(STATUS "PCRE2 libs: Shared")
endif()
# attempt to locate using upstream config script and return if found
find_package(PCRE2 QUIET CONFIG)
if(PCRE2_FOUND)
  # ensure that on success, find module message is printed
  find_package_handle_standard_args(PCRE2 CONFIG_MODE HANDLE_COMPONENTS)
  return()
endif()

# manual search. find header and attempt to get version
find_path(PCRE2_INCLUDE_DIR pcre2.h)
if(PCRE2_INCLUDE_DIR)
  # read major + minor versions
  file(
    STRINGS ${PCRE2_INCLUDE_DIR}/pcre2.h PCRE2_VERSION
    REGEX "^#define[ ]+PCRE2_(MAJOR|MINOR)[ ]+[0-9]+")
  # strip unnecessary components and build version
  list(
    TRANSFORM PCRE2_VERSION
    REPLACE "^#define[ ]+PCRE2_(MAJOR|MINOR)[ ]+([0-9]+)" "\\2")
  list(JOIN PCRE2_VERSION "." PCRE2_VERSION)
endif()
# find library. on Windows static name has the -static suffix
# note: NO_CACHE used since PCRE2_LIBRARY has a different meaning on Windows
if(PCRE2_USE_STATIC_LIBS)
  if(WIN32)
    find_library(PCRE2_LIBRARY NAMES pcre2-8-static NO_CACHE)
  # for non-Windows, explicitly specify we want the static library. supported
  # platforms all use .a as the static library suffix fortunately
  else()
    find_library(PCRE2_LIBRARY NAMES libpcre2.a libpcre2-8.a NO_CACHE)
  endif()
# note: CMAKE_FIND_LIBRARY_PREFIXES orders the shared library suffices first
else()
  find_library(PCRE2_LIBRARY NAMES pcre2 pcre2-8 NO_CACHE)
endif()
# if on Windows and PCRE2_USE_STATIC_LIBS is not ON, look for DLL as well
if(WIN32 AND NOT PCRE2_USE_STATIC_LIBS)
  find_file(PCRE2_LIBRARY_DLL NAMES pcre2-8.dll PATH_SUFFIXES bin)
endif()
# add PCRE2::8BIT target if library found
if(PCRE2_LIBRARY)
  # for static we have some additional INTERFACE properties to add
  if(PCRE2_USE_STATIC_LIBS)
    add_library(PCRE2::8BIT STATIC IMPORTED)
    set_target_properties(
      PCRE2::8BIT PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "PCRE2_STATIC"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION "${PCRE2_LIBRARY}"
    )
  # need DLL file for shared on Windows
  elseif(WIN32 AND PCRE2_LIBRARY_DLL)
    add_library(PCRE2::8BIT SHARED IMPORTED)
    set_target_properties(
      PCRE2::8BIT PROPERTIES
      IMPORTED_IMPLIB "${PCRE2_LIBRARY}"
      IMPORTED_LOCATION "${PCRE2_LIBRARY_DLL}"
    )
  # non-Windows shared library
  else()
    add_library(PCRE2::8BIT SHARED IMPORTED)
    set_target_properties(
      PCRE2::8BIT PROPERTIES
      IMPORTED_LOCATION "${PCRE2_LIBRARY}"
    )
  endif()
endif()
# if PCRE2::8BIT target is created, set include directories + mark as found
if(TARGET PCRE2::8BIT)
  set_target_properties(
    PCRE2::8BIT PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PCRE2_INCLUDE_DIR}"
  )
  set(PCRE2_8BIT_FOUND ON)
  # for compatibility
  set(PCRE2_LIBRARIES ${PCRE2_LIBRARY})
  set(PCRE2_INCLUDE_DIRS ${PCRE2_INCLUDE_DIR})
endif()

# build list of required variables (include DLL for shared on Windows)
# note: PCRE2_LIBRARIES goes first so it shows in the message
set(_required_vars PCRE2_LIBRARIES PCRE2_INCLUDE_DIRS)
if(WIN32 AND NOT PCRE2_USE_STATIC_LIBS)
  list(APPEND _required_vars PCRE2_LIBRARY_DLL)
endif()
# check required vars
find_package_handle_standard_args(PCRE2
  REQUIRED_VARS ${_required_vars}
  VERSION_VAR PCRE2_VERSION
  HANDLE_COMPONENTS)
# hide in CMake GUI unless showing advanced
mark_as_advanced(${_required_vars})
unset(_required_vars)
