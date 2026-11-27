rr3=require("cpp11_rvalue_reference3")
catch_undef_globs() -- catch "undefined" global variables

assert(rr3.funcref_takeit1(rr3.FUNCREF_DOUBLE, 3) == 6)
assert(rr3.funcref_takeit2(rr3.FUNCREF_DOUBLE, 4) == 8)
assert(rr3.funcref_takeit1(rr3.funcref_returnit1(), 5) == 10)
assert(rr3.funcref_takeit2(rr3.funcref_returnit2(), 6) == 12)
assert(not pcall(rr3.funcref_takeit1, nil, 1))
