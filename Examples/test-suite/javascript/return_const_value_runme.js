var return_const_value = require("return_const_value");

p = return_const_value.Foo_ptr.getPtr();
if ((p.getVal() != 17)) {
    throw new Error(`Runtime test1 failed. p.getVal()=${p.getVal()}`);
}

p = return_const_value.Foo_ptr.getConstPtr();
if ((p.getVal() != 17)) {
    throw new Error(`Runtime test2 failed. p.getVal()=${p.getVal()}`);
}
