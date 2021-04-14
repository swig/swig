# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

li_cwstring

if (count("ab\0ab\0ab\0", 0) != 3)
    error("failed");
endif

if (!strcmp(test1(),"Hello World"))
    error("failed");
endif

if (!strcmp(test2()," !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"))
    error("failed");
endif

if (!strcmp(test3("hello"),"hello-suffix"))
    error("failed");
endif

if (!strcmp(test4("hello"),"hello-suffix"))
    error("failed");
endif
    
if (!strcmp(test5(4),'xxxx'))
    error("failed");
endif

if (!strcmp(test6(10),'xxxxx'))
    error("failed");
endif
    
if (!strcmp(test7(),"Hello world!"))
    error("failed");
endif

if (!strcmp(test8()," !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"))
    error("failed");
endif

