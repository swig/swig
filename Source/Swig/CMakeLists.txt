target_sources(Swig_swig PRIVATE
        cwrap.c
        deprecate.c
        error.c
        extend.c
        fragment.c
        getopt.c
        include.c
        misc.c
        naming.c
        parms.c
        scanner.c
        stype.c
        symbol.c
        tree.c
        typemap.c
        typeobj.c
        typesys.c
        wrapfunc.c
        )
target_include_directories(Swig_swig PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
