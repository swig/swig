##---------------------------------------------------------------------------##
## File  : bindc/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Thu Dec 01 13:18:51 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE bindc
  EXTRASRC bindc.cxx)

# Create test executable
ADD_EXECUTABLE(bindc_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(bindc_test.exe ${SWIG_MODULE_bindc_REAL_NAME})

# Create test
ADD_TEST(NAME bindc_test COMMAND bindc_test.exe)

##---------------------------------------------------------------------------##
## end of bindc/CMakeLists.txt
##---------------------------------------------------------------------------##
