target_sources(Swig_swig PRIVATE
        doxyentity.cxx
        doxyparser.cxx
        doxytranslator.cxx
        javadoc.cxx
        pydoc.cxx
        )
target_include_directories(Swig_swig PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
