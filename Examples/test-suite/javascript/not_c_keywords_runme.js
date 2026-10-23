var not_c_keywords = require("not_c_keywords");

cs = new not_c_keywords.ComplexStruct();
cs.init();
if (cs.complex != 123) {
    throw new Error("complex not correct");
}
cs.complex = 456;

// 'this' is wrapped only for the jsc engine, the v8 and napi wrappers are compiled as C++
if (not_c_keywords.this_function !== undefined) {
    if (not_c_keywords.this_function(1) != 2) {
        throw new Error("this_function not correct");
    }
}
