project(swig)
cmake_minimum_required(VERSION 2.8)

# Project wide configuration variables
# ------------------------------------

set(SWIG_VERSION 2.0.6)
set(SWIG_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Source" CACHE INTERNAL "Path of swig sources" FORCE) 

# Configure
# ---------

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

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Tools/swigconfig.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/Source/Include/swigconfig.h)

# Compiler flags
# --------------

include_directories("${SWIG_SOURCE_DIR}/CParse"
                    "${SWIG_SOURCE_DIR}/Include"
                    "${SWIG_SOURCE_DIR}/DOH"
                    "${SWIG_SOURCE_DIR}/Swig"
                    "${SWIG_SOURCE_DIR}/Preprocessor"
                    "${SWIG_SOURCE_DIR}/Modules"
                    "${PROJECT_BINARY_DIR}/Source/Include"
)

# Pre-Build
# ---------

# Copy Lib directory into the build dist folder
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/Dist)
file(COPY ${PROJECT_SOURCE_DIR}/Lib DESTINATION ${PROJECT_BINARY_DIR}/Dist)

# add the command to generate the source code (depends on bison)
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/Source/CParse)
add_custom_command (
  OUTPUT ${PROJECT_BINARY_DIR}/Source/CParse/parser.c
  DEPENDS ${SWIG_SOURCE_DIR}/CParse/parser.y
  COMMAND bison -o ${PROJECT_BINARY_DIR}/Source/CParse/parser.c --defines=${PROJECT_BINARY_DIR}/Source/Include/parser.h ${SWIG_SOURCE_DIR}/CParse/parser.y
)
set_property(SOURCE ${PROJECT_BINARY_DIR}/Source/CParse/parser.c PROPERTY GENERATED 1)
set_property(SOURCE ${PROJECT_BINARY_DIR}/Source/CParse/parser.h PROPERTY GENERATED 1)

# generate swigwarn.swg
file(READ ${SWIG_SOURCE_DIR}/Include/swigwarn.h SWIG_WARN_H)
string(REGEX REPLACE "#define WARN([^ \\t]*)[ \\t]*([0-9]+)" "%define SWIGWARN\\1 \\2 %enddef" SWIG_WARN_SWG ${SWIG_WARN_H})
file(WRITE ${PROJECT_BINARY_DIR}/Dist/Lib/swigwarn.swg ${SWIG_WARN_SWG})
set_property(SOURCE ${PROJECT_BINARY_DIR}/Dist/Lib/swigwarn.swg PROPERTY GENERATED 1)

# Libraries
# ---------

add_library(cparse "${SWIG_SOURCE_DIR}/CParse/cscanner.c" 
                        "${SWIG_SOURCE_DIR}/CParse/templ.c" 
                        "${SWIG_SOURCE_DIR}/CParse/util.c"
                        "${PROJECT_BINARY_DIR}/Source/CParse/parser.c"
                        "${PROJECT_BINARY_DIR}/Source/CParse/parser.h"
)                        

add_library(preprocessor "${SWIG_SOURCE_DIR}/Preprocessor/cpp.c" 
                        "${SWIG_SOURCE_DIR}/Preprocessor/expr.c"
)

add_library(doh    "${SWIG_SOURCE_DIR}/DOH/base.c"
                        "${SWIG_SOURCE_DIR}/DOH/file.c"
                        "${SWIG_SOURCE_DIR}/DOH/fio.c"
                        "${SWIG_SOURCE_DIR}/DOH/hash.c"
                        "${SWIG_SOURCE_DIR}/DOH/list.c"
                        "${SWIG_SOURCE_DIR}/DOH/memory.c"
                        "${SWIG_SOURCE_DIR}/DOH/string.c"
                        "${SWIG_SOURCE_DIR}/DOH/void.c"
)

add_library(core "${SWIG_SOURCE_DIR}/Swig/cwrap.c"
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

add_library(modules "${SWIG_SOURCE_DIR}/Modules/allegrocl.cxx"
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
                    "${SWIG_SOURCE_DIR}/Modules/javascript.cxx"
                    "${SWIG_SOURCE_DIR}/Modules/lang.cxx"
                    "${SWIG_SOURCE_DIR}/Modules/lua.cxx"
                    "${SWIG_SOURCE_DIR}/Modules/modula3.cxx"
                    "${SWIG_SOURCE_DIR}/Modules/module.cxx"
                    "${SWIG_SOURCE_DIR}/Modules/mzscheme.cxx"
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

target_link_libraries(swig cparse preprocessor doh core modules)

# copy binary into Dist folder
get_property(SWIG_EXECUTABLE TARGET swig PROPERTY LOCATION)
add_custom_command(TARGET swig POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy ${SWIG_EXECUTABLE} ${PROJECT_BINARY_DIR}/Dist
)
