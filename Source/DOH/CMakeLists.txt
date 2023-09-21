target_sources(Swig_swig PRIVATE
        base.c
        void.c
        string.c
        memory.c
        list.c
        hash.c
        fio.c
        file.c
        )
target_include_directories(Swig_swig PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
