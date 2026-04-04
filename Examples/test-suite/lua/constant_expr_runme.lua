local v=require("constant_expr")

assert(v.XX == 0)
assert(not v.xx()) -- type boolean in C++
assert(v.YY == 1)
assert(v.yy()) -- type boolean in C++

assert(v.s2a ==  10)
assert(v.s2b ==  10)
assert(v.s4a ==  11 * v.s5a)
assert(v.s4b ==  11 * v.s5b)

assert(v.WSTRING_LIT_LEN1 == 4)
assert(v.WSTRING_LIT_LEN2 == 4)
assert(v.WSTRING_LIT_LEN3 == 4)
