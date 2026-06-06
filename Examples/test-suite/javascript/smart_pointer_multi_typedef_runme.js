var smart_pointer_multi_typedef = require("smart_pointer_multi_typedef");

f = new smart_pointer_multi_typedef.Foo();
b = new smart_pointer_multi_typedef.Bar(f);
s = new smart_pointer_multi_typedef.Spam(b);
g = new smart_pointer_multi_typedef.Grok(b);

s.x = 3;
if (s.getx() != 3) {
    throw new Error;
}

g.x = 4;
if (g.getx() != 4) {
    throw new Error;
}
