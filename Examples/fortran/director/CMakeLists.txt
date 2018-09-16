##---------------------------------------------------------------------------##
## File  : director/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Sun Mar 11 11:10:49 2018
## Brief : TriBITS package file for director/
##---------------------------------------------------------------------------##

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE director
  EXTRASRC director.cxx)

# Create test executable
ADD_EXECUTABLE(director_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(director_test.exe ${SWIG_MODULE_director_REAL_NAME})

# Create test
ADD_TEST(NAME director_test COMMAND director_test.exe)

##---------------------------------------------------------------------------##
## end of director/CMakeLists.txt
##---------------------------------------------------------------------------##
