#---------------------------------------------------------------------------##
## File  : except/CMakeLists.txt
## Author: Seth R Johnson
## Date  : Thu Mar 02 10:54:30 2017
## Brief : TriBITS package file for exceptions/
## Copyright (c) 2017 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

SET(CMAKE_Fortran_FLAGS "-cpp ${CMAKE_Fortran_FLAGS}")

# Generate SWIG module
MAKE_SWIG(MODULE except)

# Generate second SWIG module that imports the first
MAKE_SWIG(MODULE downstream
  DEPLIBS ${SWIG_MODULE_except_REAL_NAME})

# Create test executable
ADD_EXECUTABLE(except_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(except_test.exe
    ${SWIG_MODULE_except_REAL_NAME}
    ${SWIG_MODULE_downstream_REAL_NAME})

# Create test
ADD_TEST(NAME except_test COMMAND except_test.exe)

##---------------------------------------------------------------------------##
## end of except/CMakeLists.txt
##---------------------------------------------------------------------------##
