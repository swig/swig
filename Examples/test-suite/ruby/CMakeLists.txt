
find_package(Ruby)
if ( RUBY_FOUND )

  set ( ruby_test_environment 
        "RUBYLIB=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}"
      )

  include_directories ( ${RUBY_INCLUDE_DIRS} )

  test_language ( ruby ".rb" ${RUBY_EXECUTABLE} )
endif ()

