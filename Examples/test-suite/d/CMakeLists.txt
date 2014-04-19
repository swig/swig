find_program ( DMD_EXECUTABLE NAMES dmd )

if ( DMD_EXECUTABLE )
  set ( d_args "-Jpath ${CMAKE_CURRENT_BINARY_DIR} -run" )
  test_language(d ".1.d" ${DMD_EXECUTABLE})
endif ()
