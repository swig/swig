# Basic tests
add_test(NAME cmd_version COMMAND $<TARGET_FILE:Swig_swig> -version)
set_tests_properties(cmd_version PROPERTIES
		PASS_REGULAR_EXPRESSION "SWIG Version ${PROJECT_VERSION}"
)
if (SWIG_PCRE)
	add_test(NAME cmd_pcreversion COMMAND $<TARGET_FILE:Swig_swig> -pcreversion)
	set_tests_properties(cmd_pcreversion PROPERTIES
			PASS_REGULAR_EXPRESSION "PCRE2 Version: ${PCRE2_VERSION}"
	)
endif ()
add_test(NAME cmd_swiglib COMMAND $<TARGET_FILE:Swig_swig> -swiglib)
set_tests_properties(cmd_swiglib PROPERTIES
		PASS_REGULAR_EXPRESSION "${CMAKE_INSTALL_PREFIX}/${SWIG_LIB}"
)
add_test(NAME cmd_external_runtime COMMAND $<TARGET_FILE:Swig_swig> -external-runtime ext_rt.h)
set_tests_properties(cmd_external_runtime PROPERTIES
		ENVIRONMENT "SWIG_LIB=${PROJECT_BINARY_DIR}/Lib")

# TODO: Add examples as tests
