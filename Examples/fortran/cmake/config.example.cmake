# cd BUILD
# cmake -C PATH_TO/config.cmake PATH_TO/swig/fortran/barefunction

SET(CMAKE_CXX_COMPILER "/opt/local/bin/g++" CACHE PATH "")
SET(CMAKE_C_COMPILER "/opt/local/bin/gcc" CACHE PATH "")
SET(CMAKE_Fortran_COMPILER "/opt/local/bin/gfortran" CACHE PATH "")

SET(SWIG_EXECUTABLE "/Users/s3j/_code/_build/swig-debug/swig" CACHE PATH "")
SET(SWIG_DIR "/Users/s3j/_local/swig-debug/share/3.0.10" CACHE PATH "")

SET(BUILD_SHARED_LIBS ON CACHE BOOL "")
SET(CMAKE_BUILD_TYPE Debug CACHE STRING "")
