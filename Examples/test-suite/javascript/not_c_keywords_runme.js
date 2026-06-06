var not_c_keywords = require("not_c_keywords");

cs = new not_c_keywords.ComplexStruct();
cs.init();
if (cs.complex != 123) {
    throw new Error("complex not correct");
}
cs.complex = 456;
