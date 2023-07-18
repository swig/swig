var not_c_keywords = require("not_c_keywords");

var cs = new not_c_keywords.ComplexStruct();
/* await */(cs.init());
if (cs.complex != 123) {
    throw new Error("complex not correct");
}
cs.complex = 456;
