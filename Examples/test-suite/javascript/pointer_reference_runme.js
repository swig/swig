var pointer_reference = require("pointer_reference");

s = pointer_reference.get();
if (s.value != 10) {
    throw new Error("get test failed");
}

ss = new pointer_reference.Struct(20);
pointer_reference.set(ss);
if (pointer_reference.Struct.instance.value != 20) {
    throw new Error("set test failed");
}

if (pointer_reference.overloading(1) != 111) {
    throw new Error("overload test 1 failed");
}

if (pointer_reference.overloading(ss) != 222) {
    throw new Error("overload test 2 failed");
}
