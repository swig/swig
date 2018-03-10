##---------------------------------------------------------------------------##
## File  : callback/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Fri Mar  9 11:21:21 2018
## Brief : TriBITS package file for callback/
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE callback
  EXTRASRC callback.cxx callback_ext.cxx cbext.f90)

# Create test executable
ADD_EXECUTABLE(callback_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(callback_test.exe ${SWIG_MODULE_callback_REAL_NAME})

# Create test
ADD_TEST(NAME callback_test COMMAND callback_test.exe)

##---------------------------------------------------------------------------##
## end of callback/CMakeLists.txt
##---------------------------------------------------------------------------##
