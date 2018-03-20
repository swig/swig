##---------------------------------------------------------------------------##
## File  : arrayview/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Tue Dec 06 11:46:55 2016
## Brief : TriBITS package file for arrayview/
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE arrayview)

# Create test executable
ADD_EXECUTABLE(arrayview_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(arrayview_test.exe ${SWIG_MODULE_arrayview_REAL_NAME})

# Create test
ADD_TEST(NAME arrayview_test COMMAND arrayview_test.exe)

##---------------------------------------------------------------------------##
## end of arrayview/CMakeLists.txt
##---------------------------------------------------------------------------##
