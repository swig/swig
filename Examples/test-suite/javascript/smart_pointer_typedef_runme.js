var smart_pointer_typedef = require("smart_pointer_typedef");

f = new smart_pointer_typedef.Foo();
b = new smart_pointer_typedef.Bar(f);

b.x = 3;
if (b.getx() != 3) {
    throw new Error;
}

fp = b.__deref__();
fp.x = 4;
if (fp.getx() != 4) {
    throw new Error;
}
