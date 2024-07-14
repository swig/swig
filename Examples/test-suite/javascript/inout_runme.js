var inout = require("inout");

if (inout.AddOne1(1) != 2) {
    throw new Error;
}

if (JSON.stringify(inout.AddOne3(1, 1, 1)) != JSON.stringify([2, 2, 2])) {
    throw new Error;
}

if (JSON.stringify(inout.NonVoidOut(-42)) != JSON.stringify([null, 0])) {
    throw new Error;
}
