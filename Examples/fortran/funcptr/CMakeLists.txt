SET(CMAKE_Fortran_FLAGS "-cpp ${CMAKE_Fortran_FLAGS}")

# Build C++ library
INCLUDE_DIRECTORIES(${CMAKE_PROJECT_SOURCE_DIR})

# Generate SWIG module
MAKE_SWIG(C MODULE funcptr
  EXTRASRC funcptr.c)

# Create test executable
add_executable(funcptr_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(funcptr_test.exe ${SWIG_MODULE_funcptr_REAL_NAME})

# Create test
ADD_TEST(NAME funcptr_test COMMAND funcptr_test.exe)
