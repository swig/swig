local v=require("member_funcptr_galore")
catch_undef_globs() -- catch "undefined" global variables

local m = v.MemberFuncPtrs()
assert(m:aaa1(v.cc1) == 0)
assert(m:aaa6(v.cc6) == 0)
assert(m:aaa7(v.cc7) == 0)
assert(m:bbb1(v.pp1) == 0)
assert(m:bbb6(v.pp6) == 0)
assert(m:bbb7(v.pp7) == 0)
assert(v.call1(v.ADD_BY_VALUE, 1, 2) == 3)

-- A const reference to a member pointer is passed and returned as the member pointer
assert(m:aaa7(v.cc1) == 0)
assert(m:aaa1(v.cc7) == 0)

-- A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
assert(not pcall(function() m:aaa1(v.pp1) end))
assert(not pcall(function() m:aaa7(v.pp7) end))
assert(not pcall(function() m:bbb1(v.cc1) end))
assert(not pcall(function() m:bbb7(v.cc7) end))
