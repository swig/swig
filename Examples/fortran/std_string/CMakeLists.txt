##---------------------------------------------------------------------------##
## File  : std_string/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Mon Dec 05 18:31:18 2016
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

#SET(CMAKE_CXX_FLAGS "-std=c++11")

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(std_stringlib stdstr.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE stdstr
  DEPLIBS std_stringlib)

# Create test executable
add_executable(std_string_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(std_string_test.exe ${SWIG_MODULE_stdstr_REAL_NAME})

# Create test
ADD_TEST(NAME std_string_test COMMAND std_string_test.exe)

##---------------------------------------------------------------------------##
## end of std_string/CMakeLists.txt
##---------------------------------------------------------------------------##
