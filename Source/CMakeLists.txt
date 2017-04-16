

set ( SOURCEFILES "" CACHE INTERNAL "List of source files to compile" )
macro ( swig_add_source_file FILENAME )
  if (IS_ABSOLUTE ${FILENAME})
    set (sf ${SOURCEFILES} ${FILENAME})
  else ()
    set ( sf ${SOURCEFILES} ${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME} )
  endif ()
  set ( SOURCEFILES ${sf} CACHE INTERNAL "List of source files to compile" )
endmacro ( swig_add_source_file )

set ( INTERNAL_INCLUDE_DIRS "" CACHE INTERNAL "List of directories with header files needed for build" )
macro ( swig_add_current_dir_to_include_dirs )
  set ( inc_dirs ${INTERNAL_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR} )
  set ( INTERNAL_INCLUDE_DIRS ${inc_dirs} CACHE INTERNAL "List of directories with header files needed for build" )
endmacro ( swig_add_current_dir_to_include_dirs )

add_subdirectory ( Include )
add_subdirectory ( CParse )
add_subdirectory ( DOH )
add_subdirectory ( Modules )
add_subdirectory ( Preprocessor )
add_subdirectory ( Swig )

set_source_files_properties ( ${CMAKE_CURRENT_BINARY_DIR}/CParse/parser.c PROPERTIES GENERATED TRUE )

include_directories(${INTERNAL_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR}/Include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/CParse)


add_executable ( swig ${SOURCEFILES} )
add_dependencies(swig generate_parser)

if ( PCRE_FOUND )
  target_link_libraries(swig ${PCRE_LIBRARIES})
endif ()

install ( TARGETS swig DESTINATION bin )



