##---------------------------------------------------------------------------##
## File  : inheritance/CMakeLists.txt
## Author: Mitchell TH Young
## Date  : Mon Jan  2 2017
## Copyright (c) 2016 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

SET(CMAKE_Fortran_FLAGS "-cpp ${CMAKE_Fortran_FLAGS}")
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(MODULE inheritance
  EXTRASRC inheritance.cxx)

# Create test executable
add_executable(inheritance_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(inheritance_test.exe ${SWIG_MODULE_inheritance_REAL_NAME})

# Create test
ADD_TEST(NAME inheritance_test COMMAND inheritance_test.exe)

##---------------------------------------------------------------------------##
## end of inheritance/CMakeLists.txt
##---------------------------------------------------------------------------##
