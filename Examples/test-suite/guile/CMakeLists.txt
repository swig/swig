find_package(PkgConfig)
pkg_check_modules(PC_GUILE guile-2.0)

FIND_PATH(GUILE_INCLUDE_DIR libguile.h
  PATH_SUFFIXES guile guile/2.0
  PATHS ${PC_GUILE_INCLUDEDIR})

FIND_LIBRARY(GUILE_LIBRARIES NAMES libguile-2.0
  PATHS ${PC_LIBUSB_LIBDIR} ${PC_LIBUSB_LIBRARY_DIRS})

find_program ( GUILE_EXECUTABLE NAMES guile )

if (GUILE_EXECUTABLE)

  set ( guile_test_environment 
        "GUILE_LOAD_PATH=${CMAKE_CURRENT_BINARY_DIR}"
      )

  include_directories(${GUILE_INCLUDE_DIR})
  
  test_language(guile ".scm" ${GUILE_EXECUTABLE})
endif ()