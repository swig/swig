target_sources(Swig_swig PRIVATE
        cpp.c
        expr.c
        )
target_include_directories(Swig_swig PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
