

find_program(OCTAVE_EXECUTABLE NAMES octave)
if (OCTAVE_EXECUTABLE)
  execute_process ( COMMAND ${OCTAVE_EXECUTABLE} --silent --eval "printf('%s', octave_config_info ('version'))"
                    OUTPUT_VARIABLE OCTAVE_VERSION_STRING
                    RESULT_VARIABLE error_code
                    OUTPUT_STRIP_TRAILING_WHITESPACE )
endif ()
find_path(OCTAVE_INCLUDE_DIR
  NAMES octave/oct.h
  PATH_SUFFIXES octave-${OCTAVE_VERSION_STRING}
)  
if (OCTAVE_EXECUTABLE AND OCTAVE_INCLUDE_DIR)
  set (OCTAVE_INCLUDE_DIRS ${OCTAVE_INCLUDE_DIR})
  set (OCTAVE_FOUND TRUE)
endif ()

if ( OCTAVE_FOUND ) 

  include_directories(${OCTAVE_INCLUDE_DIRS})
  list( APPEND LANGUAGES octave )
  
  test_language(octave ".m" ${OCTAVE_EXECUTABLE})
endif ()