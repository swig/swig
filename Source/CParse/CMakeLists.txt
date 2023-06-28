# Note: bison_target does not normalize BISON_<NAME>_OUTPUT_SOURCE
# Specifying ${CMAKE_CURRENT_BINARY_DIR} explicitly in order to get the correct path
bison_target(Swig parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)

target_sources(Swig_swig PRIVATE
        cscanner.c
        templ.c
        util.c
        )
# Note: bug https://discourse.cmake.org/t/bug-with-generated-file-and-target-sources-private/5262
# https://gitlab.kitware.com/cmake/cmake/-/issues/18399
target_sources(Swig_swig PRIVATE ${BISON_Swig_OUTPUT_SOURCE})
# bison_target only offers add_custom_command. This does not propagate the properties though
# Define a custom_target to ensure the bison is called
add_custom_target(Swig_bison
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
add_dependencies(Swig_swig Swig_bison)
target_include_directories(Swig_swig PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR})

