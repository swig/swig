var default_arg_values = require("default_arg_values");

var d = new default_arg_values.Display();

if (/* await */(d.draw1()) != 0) {
    throw new Error;
}

if (/* await */(d.draw1(12)) != 12) {
    throw new Error;
}

var p = /* await */(default_arg_values.createPtr(123));
if (/* await */(d.draw2()) != 0) {
    throw new Error;
}

if (/* await */(d.draw2(p)) != 123) {
    throw new Error;
}

if (/* await */(d.bool0()) != false || typeof /* await */(d.bool0()) != typeof false) {
    throw new Error;
}

if (/* await */(d.bool1()) != true || typeof /* await */(d.bool1()) != typeof true) {
    throw new Error;
}

if (/* await */(d.mybool0()) != false || typeof /* await */(d.mybool0()) != typeof false) {
    throw new Error;
}

if (/* await */(d.mybool1()) != true || typeof /* await */(d.mybool1()) != typeof false) {
    throw new Error;
}
