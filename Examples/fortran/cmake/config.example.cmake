# cd BUILD
# cmake -C PATH_TO/config.cmake PATH_TO/swig/Examples/fortran

SET(CMAKE_CXX_COMPILER "/opt/local/bin/g++-mp-7" CACHE PATH "")
SET(CMAKE_C_COMPILER "/opt/local/bin/gcc-mp-7" CACHE PATH "")
SET(CMAKE_Fortran_COMPILER "/opt/local/bin/gfortran-mp-7" CACHE PATH "")

SET(SWIG_EXECUTABLE "/rnsdhpc/code/build/swig-debug/swig" CACHE PATH "")
SET(SWIG_DIR "/rnsdhpc/code/install/swig-debug/share/swig/4.0.0" CACHE PATH "")

SET(BUILD_SHARED_LIBS ON CACHE BOOL "")
SET(CMAKE_BUILD_TYPE Debug CACHE STRING "")

# Search for MPI compilers
SET(USE_MPI ON CACHE BOOL "")
