var inout_typemaps = require("inout_typemaps");

if (inout_typemaps.AddOne1(1) != 2) {
    throw new Error;
}

if (JSON.stringify(inout_typemaps.AddOne3(1, 1, 1)) != JSON.stringify([2, 2, 2])) {
    throw new Error;
}

if (JSON.stringify(inout_typemaps.NonVoidOut(-42)) != JSON.stringify([null, 0])) {
    throw new Error;
}
