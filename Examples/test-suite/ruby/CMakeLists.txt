set ( ruby_test_environment 
      "RUBYLIB=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}"
    )

include_directories ( ${RUBY_INCLUDE_DIRS} )

add_tests(ruby)