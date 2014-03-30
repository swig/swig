cmake_minimum_required (VERSION 3.2)

if (NOT DEFINED CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE Release CACHE STRING "Build type")
endif ()

project (swig)

file (STRINGS configure.ac line LIMIT_COUNT 1 REGEX "AC_INIT\\(.*\\)" )
if (line MATCHES "AC_INIT\\(\\[(.*)\\],[ \t]*\\[(.*)\\],[ \t]*\\[(.*)\\]\\)" )
  set (SWIG_VERSION ${CMAKE_MATCH_2})
  set (PACKAGE_BUGREPORT ${CMAKE_MATCH_3})
else ()
  message (SEND_ERROR "Could not parse version from configure.ac")
endif ()

set(SWIG_ROOT ${PROJECT_SOURCE_DIR})

set (SWIG_LIB share/swig/${SWIG_VERSION})

# Project wide configuration variables
# ------------------------------------

set(SWIG_SOURCE_DIR ${SWIG_ROOT}/Source CACHE INTERNAL "Path of swig sources" FORCE)

set ( PACKAGE_NAME swig )
set ( PACKAGE_VERSION ${SWIG_VERSION} )

# Options
# -------

# TODO...


# Configure
# ---------

list (APPEND CMAKE_MODULE_PATH ${SWIG_ROOT}/Tools/cmake)

include(CheckIncludeFiles)
include(CheckIncludeFile)
include(CheckTypeSize)
include(CheckSymbolExists)
include(CheckLibraryExists)
include(CheckCSourceCompiles)

# HACK: didn't get the bool check working for Visual Studio 2008
if(MSVC)
set(HAVE_BOOL 1)
else()
set(CMAKE_EXTRA_INCLUDE_FILES stdbool.h)
check_type_size("bool" HAVE_BOOL)
set(CMAKE_EXTRA_INCLUDE_FILES)
endif()

check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("memory.h" HAVE_MEMORY_H)
check_include_file("stddef.h" HAVE_STDDEF_H)
check_include_file("stdint.h" HAVE_STDINT_H)
check_include_file("stdlib.h" HAVE_STDLIB_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_files( "stdlib.h;stdarg.h;string.h;float.h" HAVE_STDC_HEADERS )

check_library_exists(dl dlopen "" HAVE_LIBDL)

find_package (PCRE REQUIRED)
if (PCRE_FOUND)
  add_definitions (-DHAVE_PCRE)
  include_directories (${PCRE_INCLUDE_DIRS})
endif()

configure_file (${SWIG_ROOT}/Tools/cmake/swigconfig.h.in
                ${CMAKE_CURRENT_BINARY_DIR}/Source/Include/swigconfig.h)

find_package (BISON REQUIRED)


# Compiler flags
# --------------

include_directories(
    ${SWIG_SOURCE_DIR}/CParse
    ${SWIG_SOURCE_DIR}/Include
    ${SWIG_SOURCE_DIR}/DOH
    ${SWIG_SOURCE_DIR}/Swig
    ${SWIG_SOURCE_DIR}/Preprocessor
    ${SWIG_SOURCE_DIR}/Modules
    ${PROJECT_BINARY_DIR}/Source/Include
    ${PROJECT_BINARY_DIR}/Source/CParse
    ${PROJECT_SOURCE_DIR}/Source/Doxygen
)

# generate the parser source code (depends on bison)
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/Source/CParse)

BISON_TARGET(swig_parser
    ${SWIG_SOURCE_DIR}/CParse/parser.y
    ${PROJECT_BINARY_DIR}/Source/CParse/parser.c
)

# generate swigwarn.swg
file(READ ${SWIG_SOURCE_DIR}/Include/swigwarn.h SWIG_WARN_H)
string(REGEX REPLACE "#define WARN([^ \\t]*)[ \\t]*([0-9]+)" "%define SWIGWARN\\1 \\2 %enddef" SWIG_WARN_SWG ${SWIG_WARN_H})
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/swigwarn.swg ${SWIG_WARN_SWG})
set_property(SOURCE ${CMAKE_CURRENT_BINARY_DIR}/swigwarn.swg PROPERTY GENERATED 1)

# install lib
install (DIRECTORY ${SWIG_ROOT}/Lib/ DESTINATION ${SWIG_LIB})
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/swigwarn.swg DESTINATION ${SWIG_LIB})

# Libraries
# ---------

file (GLOB CPARSE_SOURCES ${SWIG_SOURCE_DIR}/CParse/*.c)
add_library (cparse ${CPARSE_SOURCES}
    ${PROJECT_BINARY_DIR}/Source/CParse/parser.c
    ${PROJECT_BINARY_DIR}/Source/CParse/parser.h
)

file (GLOB PREPROCESSOR_SOURCES ${SWIG_SOURCE_DIR}/Preprocessor/*.c)
add_library (preprocessor ${PREPROCESSOR_SOURCES})

file (GLOB DOH_SOURCES ${SWIG_SOURCE_DIR}/DOH/*.c)
add_library (doh ${DOH_SOURCES})

file (GLOB DOXYGEN_SOURCES ${SWIG_SOURCE_DIR}/Doxygen/*.cxx)
add_library (doxygen ${DOXYGEN_SOURCES})

file (GLOB CORE_SOURCES ${SWIG_SOURCE_DIR}/Swig/*.c)
add_library (core ${CORE_SOURCES})
if (PCRE_FOUND)
  target_link_libraries (core ${PCRE_LIBRARIES})
endif ()

file (GLOB MODULES_SOURCES ${SWIG_SOURCE_DIR}/Modules/*.cxx)
add_library (modules ${MODULES_SOURCES}
    ${PROJECT_BINARY_DIR}/Source/Include/swigconfig.h
    ${SWIG_SOURCE_DIR}/Include/swigwarn.h
)
target_link_libraries(modules doxygen)

add_executable(swig
    ${SWIG_SOURCE_DIR}/Modules/main.cxx
    ${SWIG_SOURCE_DIR}/Modules/swigmain.cxx
)

target_link_libraries (swig cparse preprocessor doh core modules)
install (TARGETS swig DESTINATION bin)


# 'make package-source' creates tarballs
set ( CPACK_PACKAGE_NAME ${PACKAGE_NAME} )
set ( CPACK_SOURCE_GENERATOR "TGZ;TBZ2" )
set ( CPACK_SOURCE_IGNORE_FILES "/.git;/build;.*~;${CPACK_SOURCE_IGNORE_FILES}" )
set ( CPACK_SOURCE_PACKAGE_FILE_NAME ${PACKAGE_NAME}-${PACKAGE_VERSION} )
include ( CPack )

enable_testing()
add_test (NAME cmd_version COMMAND swig -version)
add_test (NAME cmd_external_runtime COMMAND swig -external-runtime ext_rt.h)
set_tests_properties(cmd_external_runtime PROPERTIES ENVIRONMENT "SWIG_LIB=${PROJECT_SOURCE_DIR}/Lib")
