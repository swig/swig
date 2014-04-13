
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

