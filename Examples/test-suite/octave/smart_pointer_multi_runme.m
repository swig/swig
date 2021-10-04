smart_pointer_multi

f = Foo();
b = Bar(f);
s = Spam(b);
g = Grok(b);

s.x = 3;
if (s.getx() != 3)
    error("failed");
endif

g.x = 4;
if (g.getx() != 4)
    error("failed");
endif

