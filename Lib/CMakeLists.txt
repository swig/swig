# Copy all files to binary so that it is usable for tests
# Other files like swigwarn.swg write directly to the binary_dir
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/)

if (SWIG_INSTALL)
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ DESTINATION ${SWIG_LIB}
            FILES_MATCHING
            # Only install .i, .c, .swg and folder files
            REGEX "(.i$|.c$|.swg$|${CMAKE_CURRENT_BINARY_DIR}/.*/)"
            )
endif ()
