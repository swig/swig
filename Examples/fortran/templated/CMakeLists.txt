##---------------------------------------------------------------------------##
## File  : templated/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Thu Dec 01 13:18:51 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE templated
  EXTRASRC templated.cxx)

# Create test executable
ADD_EXECUTABLE(templated_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(templated_test.exe ${SWIG_MODULE_templated_REAL_NAME})

# Create test
ADD_TEST(NAME templated_test COMMAND templated_test.exe)

##---------------------------------------------------------------------------##
## end of templated/CMakeLists.txt
##---------------------------------------------------------------------------##
