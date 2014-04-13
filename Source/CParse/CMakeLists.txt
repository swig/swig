swig_add_current_dir_to_include_dirs ()

swig_add_source_file ( cscanner.c )
swig_add_source_file ( parser.y )
swig_add_source_file ( util.c )
swig_add_source_file ( templ.c )

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/parser.c ${CMAKE_CURRENT_BINARY_DIR}/parser.h
                   COMMAND ${BISON_EXECUTABLE} -y -d ${CMAKE_CURRENT_SOURCE_DIR}/parser.y 
                   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/y.tab.c ${CMAKE_CURRENT_BINARY_DIR}/parser.c
                   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/y.tab.h ${CMAKE_CURRENT_BINARY_DIR}/parser.h
                  )
add_custom_target ( generate_parser DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/parser.c )

swig_add_source_file (  ${CMAKE_CURRENT_BINARY_DIR}/parser.c )

