var struct_initialization = require("struct_initialization");

if (struct_initialization.instanceC1.x != 10) {
    throw new Error;
}

if (struct_initialization.instanceD1.x != 10) {
    throw new Error;
}

if (struct_initialization.instanceD2.x != 20) {
    throw new Error;
}

if (struct_initialization.instanceD3.x != 30) {
    throw new Error;
}

if (struct_initialization.instanceE1.x != 1) {
    throw new Error;
}

if (struct_initialization.instanceF1.x != 1) {
    throw new Error;
}
