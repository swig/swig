
find_library(R_LIBRARY NAMES R
              PATH_SUFFIXES R/lib 
)
find_path(R_INCLUDE_DIR NAMES R.h
          PATH_SUFFIXES R
          )

set (R_INCLUDE_DIRS ${R_INCLUDE_DIR})

find_program(R_EXECUTABLE NAMES R)

if (R_EXECUTABLE AND R_INCLUDE_DIR AND R_LIBRARY)
  set (R_FOUND TRUE)
endif ()

if ( R_FOUND )

  set(r_args "--vanilla -f")
  include_directories ( ${R_INCLUDE_DIRS} )

  test_language ( r ".R" ${R_EXECUTABLE} )
endif ()

