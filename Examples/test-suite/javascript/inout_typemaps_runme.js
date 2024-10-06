var inout_typemaps = require("inout_typemaps");

if (inout_typemaps.AddOne1(1) != 2) {
    throw new Error;
}

if (JSON.stringify(inout_typemaps.AddOne3(10, 20, 30)) != JSON.stringify([11, 21, 31])) {
    throw new Error;
}

if (JSON.stringify(inout_typemaps.NonVoidOut(-42)) != JSON.stringify([null, 0])) {
    throw new Error;
}
