var default_arg_values = require("default_arg_values");

var d = new default_arg_values.Display();

if (d.draw1() != 0) {
    throw new Error;
}

if (d.draw1(12) != 12) {
    throw new Error;
}

p = default_arg_values.createPtr(123);
if (d.draw2() != 0) {
    throw new Error;
}

if (d.draw2(p) != 123) {
    throw new Error;
}

if (d.bool0() != false || typeof d.bool0() != typeof false) {
    throw new Error;
}

if (d.bool1() != true || typeof d.bool1() != typeof true) {
    throw new Error;
}

if (d.mybool0() != false || typeof d.mybool0() != typeof false) {
    throw new Error;
}

if (d.mybool1() != true || typeof d.mybool1() != typeof false) {
    throw new Error;
}
