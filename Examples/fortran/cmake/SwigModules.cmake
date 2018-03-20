##############################################################################
# File  : fortran/cmake/SwigModules.cmake
# Author: Seth Johnson
# Date  : Wednesday July 18 17:5:36 2012
#----------------------------------------------------------------------------#
# Copyright (C) 2012 Oak Ridge National Laboratory, UT-Battelle, LLC.
##############################################################################

IF (NOT DEFINED SWIG_DIR)
  MESSAGE(FATAL_ERROR "SWIG not loaded.")
ENDIF()

IF ("${CMAKE_VERSION}" VERSION_LESS "3.8.0")
  # Old cmake that doesn't have support for non-'module' libraries: load a
  # replacement for UseSWIG and define the "swig_add_library" macro
  LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/old_cmake)
  MACRO(swig_add_library NAME)
    cmake_parse_arguments(_SAM "" "LANGUAGE;TYPE" "SOURCES" ${ARGN})
    SET(SWIG_LIBRARY_TYPE ${_SAM_TYPE})
    SWIG_ADD_MODULE(${NAME} ${_SAM_LANGUAGE} ${_SAM_SOURCES})
  ENDMACRO()
ENDIF()

# Load SWIG and other modules we need
INCLUDE(UseSWIG)
INCLUDE(CMakeParseArguments)
INCLUDE(CheckCXXCompilerFlag)

# Tell SWIG to use modern Python code
LIST(APPEND CMAKE_SWIG_PYTHON_FLAGS "-modern" "-noproxydel")

# If python version is high enough, add -py3 flag
IF(PYTHON_VERSION_STRING VERSION_GREATER 3.0)
  LIST(APPEND CMAKE_SWIG_PYTHON_FLAGS "-py3")
ENDIF()

# Define extra output files
set(SWIG_FORTRAN_EXTRA_FILE_EXTENSION "f90") # old CMake UseSWIG
set(SWIG_FORTRAN_EXTRA_FILE_EXTENSIONS ".f90")# new CMake UseSWIG

##---------------------------------------------------------------------------##
# Look through a header/SWIG file and find dependencies

MACRO(get_swig_dependencies _RESULT_VAR _SOURCE)
  # Search for dependencies in the SWIG file
  FILE(STRINGS ${_SOURCE} HEADER_FILES
    REGEX "^[ \t]*%include *\""
    )
  LIST(REMOVE_DUPLICATES HEADER_FILES)

  # Set up test directories
  SET(TEST_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

  # Get just the file names inside each "include"
  SET(${_RESULT_VAR})
  FOREACH(THEFILE ${HEADER_FILES})
    STRING(REGEX REPLACE "^.*\"([^\"]+)\".*$" "\\1" THEFILE ${THEFILE})
    IF( THEFILE )
      FOREACH(TESTDIR ${TEST_DIRS})
        IF(EXISTS ${TESTDIR}/${THEFILE})
          LIST(APPEND ${_RESULT_VAR} ${TESTDIR}/${THEFILE})
          BREAK()
        ENDIF()
      ENDFOREACH()
    ENDIF()
  ENDFOREACH()
ENDMACRO()

##---------------------------------------------------------------------------##
## ADDING SWIG MODULES
##---------------------------------------------------------------------------##
# MAKE_SWIG(
#   MODULE module
#   [C]
#   [LANGUAGE fortran]
#   [SOURCE src.i]
#   [DEPLIBS lib1 [lib2 ...]]
#   [DEPMODULES module1 [module2 ...]]
#   [EXTRASRC file1 [file2 ...]]
#   )
#
# Create a SWIG-generated python module and shared object.
#
# Add the [C] flag if the input is to be treated as a C wrapper rather than C++.
#
# The MODULE argument is the name of the resulting module file. By default it
# assumes the name "module.i", but that can be overriden with the SOURCE
# argument.
#
# All libraries in DEPLIBS will be linked against each target.
#
# All other module names in DEPMODULES will be separately added as dependencies
# without being linked. This is used for TriBITS, which understands the
# inter-library linkages but not SWIG modules.
#
# The EXTRASRC argument allows additional sources to be compiled into the SWIG
# module target.

function(MAKE_SWIG)
  cmake_parse_arguments(PARSE "C" "MODULE;LANGUAGE;SOURCE"
      "DEPLIBS;DEPMODULES;EXTRASRC" ${ARGN})

  if(NOT PARSE_MODULE)
    message(SEND_ERROR "Cannot call MAKE_SWIG without MODULE")
  endif()
  set(PARSE_MODULE ${PARSE_MODULE})

  if(NOT PARSE_LANGUAGE)
    SET(PARSE_LANGUAGE FORTRAN)
  endif()
  string(TOUPPER "${PARSE_LANGUAGE}" PARSE_LANGUAGE)

  if(PARSE_SOURCE)
    set(SRC_FILE "${PARSE_SOURCE}")
  else()
    set(SRC_FILE "${PARSE_MODULE}.i")
  endif()

  if(NOT CMAKE_SWIG_OUTDIR)
    # XXX: turn this into an option passed into the function
    set(CMAKE_SWIG_OUTDIR "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  # Let SWIG know that we're compiling C++ files, and what the module is
  set_source_files_properties(${SRC_FILE} PROPERTIES
    SWIG_MODULE_NAME ${PARSE_MODULE})

  if (NOT PARSE_C)
    set_source_files_properties(${SRC_FILE} PROPERTIES
      CPLUSPLUS TRUE)
  endif()

  # Get dependencies of main SWIG source file and the files it includes
  # we can't do recursive
  set(SUBDEPS ${SRC_FILE})
  set(DEPENDENCIES)
  foreach(RECURSION 0 1 2)
    set(OLD_SUBDEPS ${SUBDEPS})
    set(SUBDEPS)
    foreach(DEPENDENCY ${OLD_SUBDEPS})
      if(DEPENDENCY MATCHES "\\.i$")
        get_swig_dependencies(SUBSUBDEPS ${DEPENDENCY})
        list(APPEND SUBDEPS ${SUBSUBDEPS})
      endif()
    endforeach()
    list(APPEND DEPENDENCIES ${SUBDEPS})
  endforeach()

  #message("Extra dependencies for ${SRC_FILE}:\n ${DEPENDENCIES}" )

  set(SWIG_MODULE_${PARSE_MODULE}_EXTRA_DEPS ${DEPENDENCIES} )

  if (PARSE_LANGUAGE STREQUAL "FORTRAN")
    set(SWIG_FORTRAN_GENERATED_SRC "${CMAKE_SWIG_OUTDIR}/${PARSE_MODULE}.f90")
    # Usually SWIG wrapper libraries need to be built as shared libraries that
    # are never linked into the CMake dependencies themselves (the "MODULE"
    # type); not the case with fortran. This relies on the patched UseSWIG.
    if(BUILD_SHARED_LIBS)
      set(SWIG_LIBRARY_TYPE SHARED)
    else()
      set(SWIG_LIBRARY_TYPE STATIC)
    endif()
  else()
    set(SWIG_LIBRARY_TYPE MODULE)
  endif()

  # Set up compiler flags
  set(_ORIG_CMAKE_SWIG_FLAGS ${CMAKE_SWIG_FLAGS})
  list(APPEND CMAKE_SWIG_FLAGS "${CMAKE_SWIG_${PARSE_LANGUAGE}_FLAGS}")

  # Create the SWIG module
  if (DEFINED TRIBITS_CMAKE_MINIMUM_REQUIRED AND PARSE_LANGUAGE STREQUAL "FORTRAN")
    # Special case for Tribits build systems is needed to propagate includes,
    # rpaths, etc.

    # XXX hack to set up link/include directories BEFORE the call to
    # TRIBITS_ADD_LIBRARY
    TRIBITS_SORT_AND_APPEND_PACKAGE_INCLUDE_AND_LINK_DIRS_AND_LIBS(
      ${PACKAGE_NAME}  LIB  LINK_LIBS)

    TRIBITS_SORT_AND_APPEND_TPL_INCLUDE_AND_LINK_DIRS_AND_LIBS(
      ${PACKAGE_NAME}  LIB  LINK_LIBS)

    PRINT_VAR(${PACKAGE_NAME}_INCLUDE_DIRS)
    #     # Add TriBITS include directories to the SWIG commands (because the
    #     # add_library call comes after the SWIG creation, the "include_directories"
    #     # command hasn't been called at this point.)
    #     FOREACH(dir ${${PACKAGE_NAME}_INCLUDE_DIRS})
    #       LIST(APPEND CMAKE_SWIG_FLAGS "-I${dir}")
    #     ENDFOREACH()

    # Generate the SWIG commands and targets
    SWIG_MODULE_INITIALIZE(${PARSE_MODULE} ${PARSE_LANGUAGE})
    SWIG_ADD_SOURCE_TO_MODULE(${PARSE_MODULE} swig_wrapper_src ${SRC_FILE})
    get_directory_property(swig_extra_clean_files ADDITIONAL_MAKE_CLEAN_FILES)
    list(APPEND swig_extra_clean_files "${swig_wrapper_src}"
      "${SWIG_FORTRAN_GENERATED_SRC}")
    set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES
                "${swig_extra_clean_files}")

    # Add as a TriBITS library
    TRIBITS_ADD_LIBRARY(${PARSE_MODULE}
      SOURCES ${PARSE_EXTRASRC}
              ${SWIG_FORTRAN_GENERATED_SRC}
              ${swig_wrapper_src})
  else()
    swig_add_library(${PARSE_MODULE}
      LANGUAGE ${PARSE_LANGUAGE}
      TYPE ${SWIG_LIBRARY_TYPE}
      SOURCES ${SRC_FILE} ${SWIG_FORTRAN_GENERATED_SRC} ${PARSE_EXTRASRC})
  endif()

  # Restore original SWIG flags
  SET(CMAKE_SWIG_FLAGS _ORIG_CMAKE_SWIG_FLAGS)

  # Mangled name of the SWIG target (export to parent)
  set(BUILT_LIBRARY ${SWIG_MODULE_${PARSE_MODULE}_REAL_NAME})
  set(SWIG_MODULE_${PARSE_MODULE}_REAL_NAME ${BUILT_LIBRARY} PARENT_SCOPE)

  # It's not always necessary to link against python libraries, but doing so
  # can turn unfortunate run-time errors (dlopen) into link-time errors.
  if(PARSE_LANGUAGE STREQUAL "PYTHON" AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    if(NOT ${PYTHON_LIBRARIES} MATCHES ".framework")
      # Turn off undefined symbol errors on Mac systems where
      # Python is not installed as a framework
      # see http://bugs.python.org/issue1602133 about _initposix issues
      set_target_properties(${BUILT_LIBRARY}
        PROPERTIES LINK_FLAGS "-undefined suppress -flat_namespace")
    else()
      # Otherwise, link against Python libraries
      swig_link_libraries(${PARSE_MODULE} ${PYTHON_LIBRARIES})
    endif()
  endif()

  # Link against other dependent libraries
  IF (PARSE_DEPLIBS)
    target_link_libraries(${BUILT_LIBRARY} ${PARSE_DEPLIBS})
  ENDIF()

  # Add intra-module dependencies
  foreach(DEPMODULE ${PARSE_DEPMODULES})
    add_dependencies(${BUILT_LIBRARY} _${DEPMODULE})
  endforeach()

  # Include the Python directory and current source directory for the SWIG
  # targets (SWIG processor and compilation of the resulting CXX file.) We don't
  # use the INCLUDE_DIRECTORIES command because because TriBITS will
  # propagate the path if we use INCLUDE_DIRECTORIES.
  # Apply SWIG_CXX_FLAGS to hide warnings and such.
  get_target_property(INCL_DIR ${BUILT_LIBRARY} INCLUDE_DIRECTORIES)
  IF(NOT INCL_DIR)
    SET(INCL_DIR "")
  ENDIF()
  list(APPEND INCL_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  if (PARSE_LANGUAGE STREQUAL "PYTHON")
    list(APPEND INCL_DIR ${PYTHON_INCLUDE_DIRS})
  endif()
  list(REMOVE_DUPLICATES INCL_DIR)
  set_target_properties(${BUILT_LIBRARY} PROPERTIES
    INCLUDE_DIRECTORIES "${INCL_DIR}"
    COMPILE_FLAGS "${SWIG_CXX_FLAGS}")

  # message(STATUS "Include directories on target ${PARSE_MODULE}: ${INCL_DIR}")

  # define the install targets
  if (PARSE_LANGUAGE STREQUAL "PYTHON")
    install(TARGETS ${BUILT_LIBRARY}
      DESTINATION python)
    install(FILES ${CMAKE_SWIG_OUTDIR}/${PARSE_MODULE}.py
      DESTINATION python)
  endif ()

  # clean up after SWIG (in cmake 2.6 - 2.8)
  set(swig_extra_generated_files)

endfunction()

##---------------------------------------------------------------------------##
## end of SwigModules.cmake
##---------------------------------------------------------------------------##
