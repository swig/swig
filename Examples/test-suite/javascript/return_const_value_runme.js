var return_const_value = require("return_const_value");

var p = /* await */(return_const_value.Foo_ptr.getPtr());
if (/* await */(p.getVal()) != 17) {
    throw new Error(`Runtime test1 failed. p.getVal()=${p.getVal()}`);
}

p = /* await */(return_const_value.Foo_ptr.getConstPtr());
if (/* await */(p.getVal()) != 17) {
    throw new Error(`Runtime test2 failed. p.getVal()=${p.getVal()}`);
}
