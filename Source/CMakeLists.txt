add_subdirectory(CParse)
add_subdirectory(DOH)
add_subdirectory(Doxygen)
add_subdirectory(Modules)
add_subdirectory(Preprocessor)
add_subdirectory(Swig)

# Misc definitions
if (SWIG_PCRE)
    set (HAVE_PCRE 1)
    target_link_libraries(Swig_swig ${PCRE2_LIBRARIES})
    include_directories(${PCRE2_INCLUDE_DIRS})
endif()

if (MSVC)
    # TODO: Document what this does
    target_compile_options(Swig_swig PRIVATE
            $<$<COMPILE_LANGUAGE:CXX>:/EHsc>)
endif ()

# Note: configure_file is defined in Include. Make sure all variables are set before
# adding it to the project
add_subdirectory(Include)

if (SWIG_INSTALL)
    install(TARGETS Swig_swig
            EXPORT SwigTargets
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Swig_Runtime
    )
endif ()
