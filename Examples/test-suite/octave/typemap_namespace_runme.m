typemap_namespace

if (!strcmp(test1("hello"),"hello"))
    error("failed");
endif

if (!strcmp(test2("hello"),"hello"))
    error("failed");
endif

