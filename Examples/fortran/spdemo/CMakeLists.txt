##---------------------------------------------------------------------------##
## File  : spdemo/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Tue Dec 06 14:55:04 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(spdemolib spdemo.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE spdemo
  DEPLIBS spdemolib)

# Create test executable
ADD_EXECUTABLE(spdemo_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(spdemo_test.exe  ${SWIG_MODULE_spdemo_REAL_NAME})

# Create test
ADD_TEST(NAME spdemo_test COMMAND spdemo_test.exe)

##---------------------------------------------------------------------------##
## end of spdemo/CMakeLists.txt
##---------------------------------------------------------------------------##
