var cpp11_null_pointer_constant = require("cpp11_null_pointer_constant");

a = new cpp11_null_pointer_constant.A();

if (a._myA != null) {
    throw new Error(
        "cpp11_null_pointer_constant: _myA should be None, but is ", a._myA);
}

b = new cpp11_null_pointer_constant.A();
if (a._myA != b._myA) {
    throw new Error(
        "cpp11_null_pointer_constant: a._myA should be the same as b._myA, but ", a._myA, "!=", b._myA);
}

a._myA = new cpp11_null_pointer_constant.A();
if (a._myA == null) {
    throw new Error((
        "cpp11_null_pointer_constant: _myA should be object, but is None"));
}
