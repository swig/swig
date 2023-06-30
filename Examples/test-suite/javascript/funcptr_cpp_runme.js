var funcptr_cpp = require("funcptr_cpp");

if (funcptr_cpp.call1(funcptr_cpp.ADD_BY_VALUE, 10, 11) != 21) {
    throw new Error;
}
if (funcptr_cpp.call2(funcptr_cpp.ADD_BY_POINTER, 12, 13) != 25) {
    throw new Error;
}
if (funcptr_cpp.call3(funcptr_cpp.ADD_BY_REFERENCE, 14, 15) != 29) {
    throw new Error;
}
if (funcptr_cpp.call1(funcptr_cpp.ADD_BY_VALUE_C, 2, 3) != 5) {
    throw new Error;
}
if (funcptr_cpp.callconst1(funcptr_cpp.ADD_BY_VALUE_C, 2, 3) != 5) {
    throw new Error;
}
