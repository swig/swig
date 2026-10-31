var cpp11_rvalue_reference3 = require("cpp11_rvalue_reference3");

if (cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 3) != 6) {
    throw new Error;
}
if (cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 4) != 8) {
    throw new Error;
}
if (cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.funcref_returnit1(), 5) != 10) {
    throw new Error;
}
if (cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.funcref_returnit2(), 6) != 12) {
    throw new Error;
}
