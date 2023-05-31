var smart_pointer_simple = require("smart_pointer_simple");

f = new smart_pointer_simple.Foo();
b = new smart_pointer_simple.Bar(f);

b.x = 3;
if (b.getx() != 3) {
    throw new Error;
}

fp = b.__deref__();
fp.x = 4;
if (fp.getx() != 4) {
    throw new Error;
}
