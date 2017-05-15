
if ( NOT IS_ABSOLUTE ${SWIG_LIB} )
  set ( SWIG_LIB ${CMAKE_INSTALL_PREFIX}/${SWIG_LIB} )
endif ()

swig_add_current_dir_to_include_dirs ()
configure_file(swigconfig.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/swigconfig.h @ONLY )
