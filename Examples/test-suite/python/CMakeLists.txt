set ( python_test_environment 
      "PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}"
    )
include_directories ( ${PYTHON_INCLUDE_DIR} )

add_tests(python)