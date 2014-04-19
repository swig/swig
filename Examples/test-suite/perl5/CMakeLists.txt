
find_package(Perl)
find_package(PerlLibs)

if ( PERL_FOUND AND PERLLIBS_FOUND)

  set ( perl_test_environment 
        "PERL5LIB=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}"
      )
  include_directories ( ${PERL_INCLUDE_PATH} )

  test_language ( perl ".pl" ${PERL_EXECUTABLE} )
endif ()

