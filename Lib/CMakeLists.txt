
file ( GLOB_RECURSE doti RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.i )
file ( GLOB_RECURSE dotswg RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.swg )

foreach ( file ${doti} )
  get_filename_component ( file_path ${file} DIRECTORY )
  install ( FILES ${file} DESTINATION ${SWIG_LIB}/${file_path} )
endforeach ()

install ( FILES chicken/multi-generic.scm chicken/swigclosprefix.scm DESTINATION ${SWIG_LIB}/chicken )
install ( FILES guile/common.scm DESTINATION ${SWIG_LIB}/guile )
install ( FILES ocaml/swig.ml ocaml/swigp4.ml DESTINATION ${SWIG_LIB}/ocaml )
install ( FILES perl5/Makefile.pl perl5/noembed.h DESTINATION ${SWIG_LIB}/perl5 )
install ( FILES ruby/extconf.rb ruby/Makefile.swig DESTINATION ${SWIG_LIB}/ruby )

# generate swigwarn.swg
set ( SWIGWARN_SWG ${CMAKE_CURRENT_BINARY_DIR}/swigwarn.swg)
if ( NOT EXISTS ${SWIGWARN_SWG} )
  file ( WRITE ${SWIGWARN_SWG} "/* SWIG Warning codes */\n\n\n" )
  file ( STRINGS ${CMAKE_SOURCE_DIR}/Source/Include/swigwarn.h SWIGWARN_H_LINES )
  foreach ( SWIGWARN_H_LINE ${SWIGWARN_H_LINES})
    string ( REGEX MATCH "^#define .* [0-9]+" _DEF_LINE ${SWIGWARN_H_LINE} )
    if (_DEF_LINE)
      string(REGEX REPLACE "#define (.* [0-9]+)" "%define SWIG\\1 %enddef" SWIGWARN_SWG_LINE ${SWIGWARN_H_LINE} )
      file ( APPEND ${SWIGWARN_SWG} "${SWIGWARN_SWG_LINE}\n" )
    endif ()
  endforeach()
endif ()
install ( FILES ${SWIGWARN_SWG} DESTINATION ${SWIG_LIB} )
