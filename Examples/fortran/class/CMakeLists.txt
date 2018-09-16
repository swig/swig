##---------------------------------------------------------------------------##
## File  : class/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Tue Dec 06 14:55:04 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(cppexamplelib example.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE example
  DEPLIBS cppexamplelib)

# Create test executable
ADD_EXECUTABLE(cppexample_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(cppexample_test.exe  ${SWIG_MODULE_example_REAL_NAME})

# Create test
ADD_TEST(NAME cppexample_test COMMAND cppexample_test.exe)

##---------------------------------------------------------------------------##
## end of class/CMakeLists.txt
##---------------------------------------------------------------------------##
