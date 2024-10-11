var inout_typemaps = require("inout_typemaps");

// FIXME: OUTPUT and INOUT typemaps generate incorrect TypeScript
// types - this is difficult to fix as it requires very substantial
// development
// https://github.com/mmomtchev/swig/issues/68
// @ts-ignore
if (/* await */(inout_typemaps.AddOne1(1)) != 2) {
    throw new Error;
}

if (JSON.stringify(/* await */(inout_typemaps.AddOne3(10, 20, 30))) != JSON.stringify([11, 21, 31])) {
    throw new Error;
}

if (JSON.stringify(/* await */(inout_typemaps.NonVoidOut(-42))) != JSON.stringify([null, 0])) {
    throw new Error;
}
