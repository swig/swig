using_protected

f = FooBar();
f.x = 3;

if (f.blah(4) != 4)
    error("blah(int)")
endif
