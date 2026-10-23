local v=require("constant_expr_c")

assert(v.XX == v.xx());
assert(v.YY == v.yy());

assert(v.s2a ==  10);
assert(v.s2b ==  10);
assert(v.s4a ==  11 * v.s5a);
assert(v.s4b ==  11 * v.s5b);
