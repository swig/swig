smart_pointer_simple

f = Foo();
b = Bar(f);

b.x = 3;
if (b.getx() != 3)
    error
endif

fp = b.__deref__();
fp.x = 4;
if (fp.getx() != 4)
    error
endif
