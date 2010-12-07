template_extend2

a = template_extend2.lBaz();
b = template_extend2.dBaz();

if (!strcmp(a.foo(),"lBaz::foo"))
    error
endif

if (!strcmp(b.foo(),"dBaz::foo"))
    error
endif
