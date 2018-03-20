##---------------------------------------------------------------------------##
## File  : simpleclass/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Thu Dec  1 15:13:04 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

SET(CMAKE_Fortran_FLAGS "-cpp ${CMAKE_Fortran_FLAGS}")

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(simpleclasslib SimpleClass.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE simple_class
  DEPLIBS simpleclasslib)

# Create test executable
ADD_EXECUTABLE(simpleclass_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(simpleclass_test.exe  ${SWIG_MODULE_simple_class_REAL_NAME})

# Create test
ADD_TEST(NAME simpleclass_test COMMAND simpleclass_test.exe)

##---------------------------------------------------------------------------##
## end of simpleclass/CMakeLists.txt
##---------------------------------------------------------------------------##
