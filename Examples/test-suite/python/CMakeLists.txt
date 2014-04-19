


find_package ( PythonInterp )
find_package ( PythonLibs )

if ( PYTHONLIBS_FOUND AND PYTHONINTERP_FOUND )

  set ( python_ext ".py" )

  set ( python_test_environment 
        "PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}"
      )
  include_directories ( ${PYTHON_INCLUDE_DIR} )

  if ( ${PYTHON_VERSION_MAJOR} VERSION_EQUAL 3 )
    find_program(PY2TO3_EXECUTABLE NAMES 2to3)
    if ( NOT PY2TO3_EXECUTABLE )
      message ( SEND_ERROR "Python 2to3 executable not found" )
    endif ()
    file(GLOB python_files "${CMAKE_CURRENT_SOURCE_DIR}/*_runme.py")
#     add_custom_target(generate-py3)
    foreach(python_file ${python_files})
      get_filename_component(BASENAME ${python_file}  NAME_WE)
      add_custom_command( OUTPUT ${python_file}3
                          COMMAND ${PY2TO3_EXECUTABLE} --write --nobackups --no-diffs --add-suffix=3 ${python_file}
                          DEPENDS ${python_file}
                        )
      add_custom_target ( generate-${BASENAME}-py3 DEPENDS ${python_file}3 )
#       add_dependencies ( generate-py3 generate-${BASENAME}-py3 )
    endforeach()

    set ( python_ext ".py3" )
  endif ()
  
  test_language ( python ${python_ext} ${PYTHON_EXECUTABLE} )
  
#   if ( PY2TO3_EXECUTABLE )
#     add_dependencies(check-python-test-suite generate-py3)
#   endif ()

endif ()