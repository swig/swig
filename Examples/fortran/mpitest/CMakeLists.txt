# File: CMakeLists.txt #

# Build C++ library
INCLUDE_DIRECTORIES(
  ${CMAKE_PROJECT_SOURCE_DIR}
  ${MPI_Fortran_INCLUDE_PATH}
  ${MPI_C_INCLUDE_PATH})

# Generate SWIG module
MAKE_SWIG(C MODULE mpitest)
# It depends on the compiled fortran module
target_link_libraries(${SWIG_MODULE_mpitest_REAL_NAME}
  ${MPI_Fortran_LIBRARIES}
  ${MPI_CXX_LIBRARIES})

# Create test executable
add_executable(mpitest_test.exe runme.f90)
# It depends on the compiled fortran module
target_link_libraries(mpitest_test.exe
  ${SWIG_MODULE_mpitest_REAL_NAME}
  ${MPI_Fortran_LIBRARIES}
  ${MPI_CXX_LIBRARIES})

# Create 4-processor test
ADD_TEST(NAME mpitest_test
  COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 4 mpitest_test.exe)
