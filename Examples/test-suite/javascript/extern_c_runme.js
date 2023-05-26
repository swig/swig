var extern_c = require("extern_c");

function check(flag) {
    if (!flag) {
        throw new Error("Test failed");
    }
}

extern_c.RealFunction(2);
check(extern_c.int2 == 123);
check(extern_c.int3 == 456);
check(extern_c.int4 == 789);
