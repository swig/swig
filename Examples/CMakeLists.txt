# Basic tests
add_test(NAME cmd_version COMMAND swig -version)
add_test(NAME cmd_pcreversion COMMAND swig -pcreversion)
add_test(NAME cmd_swiglib COMMAND swig -swiglib)
add_test(NAME cmd_external_runtime COMMAND swig -external-runtime ext_rt.h)
set_tests_properties(cmd_external_runtime PROPERTIES ENVIRONMENT "SWIG_LIB=${PROJECT_BINARY_DIR}/Lib")

# TODO: Add examples as tests
