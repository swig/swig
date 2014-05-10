configure_file(config.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/config.h )

configure_file(ccache_swig_config.h.in ${CMAKE_CURRENT_BINARY_DIR}/ccache_swig_config.h )
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set ( SOURCEFILES ccache.c mdfour.c hash.c execute.c util.c args.c stats.c cleanup.c snprintf.c unify.c )
add_executable ( ccache-swig ${SOURCEFILES} )
if ( ZLIB_FOUND )
  target_link_libraries ( ccache-swig ${ZLIB_LIBRARIES} )
endif ()
install ( TARGETS ccache-swig DESTINATION bin )


if ( YODL2MAN_EXECUTABLE )
  set ( MAN_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ccache-swig.1 )
  add_custom_command( OUTPUT ${MAN_OUTPUT}
                      COMMAND ${YODL2MAN_EXECUTABLE} -o ${MAN_OUTPUT} ${CMAKE_CURRENT_SOURCE_DIR}/ccache.yo
                      DEPENDS ccache.yo
  )
  add_custom_target ( ccache_doc ALL DEPENDS ${MAN_OUTPUT} )
  install ( FILES ${MAN_OUTPUT} DESTINATION share/man/man1 )
endif ()