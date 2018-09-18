##---------------------------------------------------------------------------##
## File  : fortran/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Tue Dec 06 11:46:55 2016
## Brief : TriBITS package file for algorithm/
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(fortran-examples C CXX Fortran)

SET(CMAKE_CXX_STANDARD 11)

ENABLE_TESTING()

# SWIG setup
FIND_PACKAGE(SWIG REQUIRED)
LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
INCLUDE(SwigModules)

# Optional MPI setup
IF (NOT DEFINED USE_MPI)
  SET(USE_MPI FALSE)
ENDIF()
IF (USE_MPI)
  FIND_PACKAGE(MPI)
  IF (MPI_Fortran_FOUND AND MPI_C_FOUND)
    MESSAGE(STATUS "Found MPI")
  ELSE()
    MESSAGE(STATUS "MPI requires both C and Fortran compilers")
    SET(USE_MPI FALSE)
  ENDIF()
ENDIF()

ADD_SUBDIRECTORY(arrayview)
ADD_SUBDIRECTORY(bare)
ADD_SUBDIRECTORY(bindc)
ADD_SUBDIRECTORY(callback)
ADD_SUBDIRECTORY(class)
ADD_SUBDIRECTORY(director)
ADD_SUBDIRECTORY(except)
ADD_SUBDIRECTORY(inheritance)
ADD_SUBDIRECTORY(simple)
ADD_SUBDIRECTORY(simpleclass)
ADD_SUBDIRECTORY(simplest)
ADD_SUBDIRECTORY(spdemo)
ADD_SUBDIRECTORY(static_members)
ADD_SUBDIRECTORY(std_string)
ADD_SUBDIRECTORY(std_vector)
ADD_SUBDIRECTORY(templated)
ADD_SUBDIRECTORY(thinvec)

IF(USE_MPI)
  ADD_SUBDIRECTORY(mpitest)
ENDIF()


##---------------------------------------------------------------------------##
## end of fortran/CMakeLists.txt
##---------------------------------------------------------------------------##
