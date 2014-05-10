find_program ( GO_EXECUTABLE NAMES go )

if ( GO_EXECUTABLE )
  set ( go_test_environment 
        "GOPATH=${CMAKE_CURRENT_BINARY_DIR}"
      )
  set(go_args "run")
  test_language(go ".go" ${GO_EXECUTABLE})
endif ()