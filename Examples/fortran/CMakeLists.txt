##---------------------------------------------------------------------------##
## File  : fortran/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Tue Dec 06 11:46:55 2016
## Brief : TriBITS package file for algorithm/
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(fortran-examples C CXX Fortran)

SET(CMAKE_CXX_STANDARD 98)

ENABLE_TESTING()

# SWIG setup
FIND_PACKAGE(SWIG REQUIRED)
LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
INCLUDE(SwigModules)

ADD_SUBDIRECTORY(arrayview)
ADD_SUBDIRECTORY(barefunctions)
ADD_SUBDIRECTORY(bindc)
ADD_SUBDIRECTORY(class)
ADD_SUBDIRECTORY(except)
ADD_SUBDIRECTORY(funcptr)
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

##---------------------------------------------------------------------------##
## end of fortran/CMakeLists.txt
##---------------------------------------------------------------------------##
