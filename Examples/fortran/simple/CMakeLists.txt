##---------------------------------------------------------------------------##
## File  : simple/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Mon Dec 05 09:05:31 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE simple
  EXTRASRC simple.cxx)

# Create test executable
add_executable(simple_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(simple_test.exe ${SWIG_MODULE_simple_REAL_NAME})

# Create test
ADD_TEST(NAME simple_test COMMAND simple_test.exe)

##---------------------------------------------------------------------------##
## end of simple/CMakeLists.txt
##---------------------------------------------------------------------------##
