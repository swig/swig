##---------------------------------------------------------------------------##
## File  : simplest/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Thu Dec 01 13:18:51 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(C MODULE simplest)

# Create test executable
ADD_EXECUTABLE(simplest_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(simplest_test.exe ${SWIG_MODULE_simplest_REAL_NAME})

# Create test
ADD_TEST(NAME simplest_test COMMAND simplest_test.exe)

##---------------------------------------------------------------------------##
## end of simplest/CMakeLists.txt
##---------------------------------------------------------------------------##
