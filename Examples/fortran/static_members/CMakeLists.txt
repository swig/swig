##---------------------------------------------------------------------------##
## File  : static_members/CMakeLists.txt
## Author: Andrey Prokopenko
## Date  : Mon Jan 21 2017
## Brief : static members example
## Copyright (c) 2017 Oak Ridge National Laboratory, UT-Battelle, LLC.
##---------------------------------------------------------------------------##

SET(CMAKE_Fortran_FLAGS "-cpp ${CMAKE_Fortran_FLAGS}")

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})
ADD_LIBRARY(staticmemberslib static_members.cxx)

# Generate SWIG module
MAKE_SWIG(MODULE static_members
  DEPLIBS staticmemberslib)

# Create test executable
ADD_EXECUTABLE(static_members_test.exe runme.f90)
# It depends on the compiled fortran module
TARGET_LINK_LIBRARIES(static_members_test.exe ${SWIG_MODULE_static_members_REAL_NAME})

# Create test
ADD_TEST(NAME static_members_test COMMAND static_members_test.exe)

##---------------------------------------------------------------------------##
## end of static_members/CMakeLists.txt
##---------------------------------------------------------------------------##
