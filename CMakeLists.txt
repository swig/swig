project(swig)

cmake_minimum_required(VERSION 2.8)

if ( NOT DEFINED CMAKE_BUILD_TYPE )
  set( CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" )
endif ()

project(swig)

set(SWIG_VERSION 3.0.0)

set(SWIG_ROOT ${PROJECT_SOURCE_DIR})

set( SWIG_LIB share/swig/${SWIG_VERSION_STRING} )

# Project wide configuration variables
# ------------------------------------

set(SWIG_SOURCE_DIR "${SWIG_ROOT}/Source" CACHE INTERNAL "Path of swig sources" FORCE)

set ( PACKAGE_NAME swig )
set ( PACKAGE_VERSION ${SWIG_VERSION} )

# Options
# -------

# TODO...


# Configure
# ---------

LIST(APPEND CMAKE_MODULE_PATH ${SWIG_ROOT}/Tools/cmake)

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

find_package(PCRE)
if (PCRE_FOUND)
    include_directories( ${PCRE_INCLUDE_DIRS} )
    set(HAVE_PCRE 1)
else()
    set(HAVE_PCRE 0)
endif()

option(USE_ZLIB "enable ccache compression" ON)
if ( USE_ZLIB )
  find_package ( ZLIB )
endif ()
if ( ZLIB_FOUND )
  set ( ENABLE_ZLIB 1 )
  include_directories ( ${ZLIB_INCLUDE_DIRS} )
else ()
  set ( ENABLE_ZLIB 0 )
endif ()

# for ccache man
find_program ( YODL2MAN_EXECUTABLE NAMES yodl2man )

configure_file(
    ${SWIG_ROOT}/Tools/cmake/swigconfig.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/Source/Include/swigconfig.h
)

find_package(BISON REQUIRED)


# Compiler flags
# --------------

include_directories(
    "${SWIG_SOURCE_DIR}/CParse"
    "${SWIG_SOURCE_DIR}/Include"
    "${SWIG_SOURCE_DIR}/DOH"
    "${SWIG_SOURCE_DIR}/Swig"
    "${SWIG_SOURCE_DIR}/Preprocessor"
    "${SWIG_SOURCE_DIR}/Modules"
    "${PROJECT_BINARY_DIR}/Source/Include"
    "${PROJECT_BINARY_DIR}/Source/CParse"
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
install ( DIRECTORY ${SWIG_ROOT}/Lib DESTINATION ${SWIG_LIB} )
install ( FILES ${CMAKE_CURRENT_BINARY_DIR}/swigwarn.swg DESTINATION ${SWIG_LIB} )

# Libraries
# ---------

add_library(cparse
    "${SWIG_SOURCE_DIR}/CParse/cscanner.c"
    "${SWIG_SOURCE_DIR}/CParse/templ.c"
    "${SWIG_SOURCE_DIR}/CParse/util.c"
    "${PROJECT_BINARY_DIR}/Source/CParse/parser.c"
    "${PROJECT_BINARY_DIR}/Source/CParse/parser.h"
)

add_library(preprocessor
    "${SWIG_SOURCE_DIR}/Preprocessor/cpp.c"
    "${SWIG_SOURCE_DIR}/Preprocessor/expr.c"
)

add_library(doh
    "${SWIG_SOURCE_DIR}/DOH/base.c"
    "${SWIG_SOURCE_DIR}/DOH/file.c"
    "${SWIG_SOURCE_DIR}/DOH/fio.c"
    "${SWIG_SOURCE_DIR}/DOH/hash.c"
    "${SWIG_SOURCE_DIR}/DOH/list.c"
    "${SWIG_SOURCE_DIR}/DOH/memory.c"
    "${SWIG_SOURCE_DIR}/DOH/string.c"
    "${SWIG_SOURCE_DIR}/DOH/void.c"
)

add_library(core
    "${SWIG_SOURCE_DIR}/Swig/cwrap.c"
    "${SWIG_SOURCE_DIR}/Swig/deprecate.c"
    "${SWIG_SOURCE_DIR}/Swig/error.c"
    "${SWIG_SOURCE_DIR}/Swig/fragment.c"
    "${SWIG_SOURCE_DIR}/Swig/getopt.c"
    "${SWIG_SOURCE_DIR}/Swig/include.c"
    "${SWIG_SOURCE_DIR}/Swig/misc.c"
    "${SWIG_SOURCE_DIR}/Swig/naming.c"
    "${SWIG_SOURCE_DIR}/Swig/parms.c"
    "${SWIG_SOURCE_DIR}/Swig/scanner.c"
    "${SWIG_SOURCE_DIR}/Swig/stype.c"
    "${SWIG_SOURCE_DIR}/Swig/symbol.c"
    "${SWIG_SOURCE_DIR}/Swig/tree.c"
    "${SWIG_SOURCE_DIR}/Swig/typemap.c"
    "${SWIG_SOURCE_DIR}/Swig/typeobj.c"
    "${SWIG_SOURCE_DIR}/Swig/typesys.c"
    "${SWIG_SOURCE_DIR}/Swig/wrapfunc.c"
)

add_library(modules
    "${SWIG_SOURCE_DIR}/Modules/allegrocl.cxx"
    "${SWIG_SOURCE_DIR}/Modules/allocate.cxx"
    "${SWIG_SOURCE_DIR}/Modules/browser.cxx"
    "${SWIG_SOURCE_DIR}/Modules/cffi.cxx"
    "${SWIG_SOURCE_DIR}/Modules/chicken.cxx"
    "${SWIG_SOURCE_DIR}/Modules/clisp.cxx"
    "${SWIG_SOURCE_DIR}/Modules/contract.cxx"
    "${SWIG_SOURCE_DIR}/Modules/csharp.cxx"
    "${SWIG_SOURCE_DIR}/Modules/d.cxx"
    "${SWIG_SOURCE_DIR}/Modules/directors.cxx"
    "${SWIG_SOURCE_DIR}/Modules/emit.cxx"
    "${SWIG_SOURCE_DIR}/Modules/go.cxx"
    "${SWIG_SOURCE_DIR}/Modules/guile.cxx"
    "${SWIG_SOURCE_DIR}/Modules/java.cxx"
    "${SWIG_SOURCE_DIR}/Modules/lang.cxx"
    "${SWIG_SOURCE_DIR}/Modules/lua.cxx"
    "${SWIG_SOURCE_DIR}/Modules/modula3.cxx"
    "${SWIG_SOURCE_DIR}/Modules/module.cxx"
    "${SWIG_SOURCE_DIR}/Modules/mzscheme.cxx"
    "${SWIG_SOURCE_DIR}/Modules/nested.cxx"
    "${SWIG_SOURCE_DIR}/Modules/ocaml.cxx"
    "${SWIG_SOURCE_DIR}/Modules/octave.cxx"
    "${SWIG_SOURCE_DIR}/Modules/overload.cxx"
    "${SWIG_SOURCE_DIR}/Modules/perl5.cxx"
    "${SWIG_SOURCE_DIR}/Modules/php.cxx"
    "${SWIG_SOURCE_DIR}/Modules/pike.cxx"
    "${SWIG_SOURCE_DIR}/Modules/python.cxx"
    "${SWIG_SOURCE_DIR}/Modules/r.cxx"
    "${SWIG_SOURCE_DIR}/Modules/ruby.cxx"
    "${SWIG_SOURCE_DIR}/Modules/s-exp.cxx"
    "${SWIG_SOURCE_DIR}/Modules/tcl8.cxx"
    "${SWIG_SOURCE_DIR}/Modules/typepass.cxx"
    "${SWIG_SOURCE_DIR}/Modules/uffi.cxx"
    "${SWIG_SOURCE_DIR}/Modules/utils.cxx"
    "${SWIG_SOURCE_DIR}/Modules/xml.cxx"
    "${PROJECT_BINARY_DIR}/Source/Include/swigconfig.h"
    "${SWIG_SOURCE_DIR}/Include/swigwarn.h"
)

add_executable(swig
    "${SWIG_SOURCE_DIR}/Modules/main.cxx"
    "${SWIG_SOURCE_DIR}/Modules/swigmain.cxx"
)

target_link_libraries ( swig cparse preprocessor doh core modules ${PCRE_LIBRARIES} )
install ( TARGETS swig DESTINATION bin )


add_subdirectory ( CCache )
enable_testing()

add_subdirectory ( Examples )

# 'make package-source' creates tarballs
set ( CPACK_PACKAGE_NAME ${PACKAGE_NAME} )
set ( CPACK_SOURCE_GENERATOR "TGZ;TBZ2" )
set ( CPACK_SOURCE_IGNORE_FILES "/.git;/build;.*~;${CPACK_SOURCE_IGNORE_FILES}" )
set ( CPACK_SOURCE_PACKAGE_FILE_NAME ${PACKAGE_NAME}-${PACKAGE_VERSION} )
include ( CPack )
