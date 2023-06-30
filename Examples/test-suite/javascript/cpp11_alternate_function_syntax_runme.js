var cpp11_alternate_function_syntax = require("cpp11_alternate_function_syntax");

a = new cpp11_alternate_function_syntax.SomeStruct();

res = a.addNormal(4, 5);
if (res != 9) {
    throw new Error("SomeStruct::addNormal(4,5) returns ", res, " should be 9.");
}

res = a.addAlternate(4, 5);
if (res != 9) {
    throw new Error("SomeStruct::addAlternate(4,5) returns ", res, " should be 9.");
}

res = a.addAlternateConst(4, 5);
if (res != 9) {
    throw new Error("SomeStruct::addAlternateConst(4,5) returns ", res, " should be 9.");
}

res = a.addAlternateNoExcept(4, 5);
if (res != 9) {
    throw new Error("SomeStruct::addAlternateNoExcept(4,5) returns ", res, " should be 9.");
}

res = a.addAlternateConstNoExcept(4, 5);
if (res != 9) {
    throw new Error("SomeStruct::addAlternateConstNoExcept(4,5) returns ", res, " should be 9.");
}
