##---------------------------------------------------------------------------##
## File  : std_vector/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Mon Dec 05 09:05:31 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

#SET(CMAKE_CXX_FLAGS "-std=c++11")

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(stdveclib stdvec.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE stdvec
  DEPLIBS stdveclib)

# Create test executable
add_executable(std_vector_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(std_vector_test.exe ${SWIG_MODULE_stdvec_REAL_NAME})

# Create test
ADD_TEST(NAME std_vector_test COMMAND std_vector_test.exe)

##---------------------------------------------------------------------------##
## end of std_vector/CMakeLists.txt
##---------------------------------------------------------------------------##
