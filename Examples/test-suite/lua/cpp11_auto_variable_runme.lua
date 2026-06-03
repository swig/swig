local v=require("cpp11_auto_variable")



assert(not v.f)
assert(swig_type(v.f) == "boolean")
assert(v.t)
assert(swig_type(v.t) == "boolean")

v.t = false
assert(not v.t)

assert(v.zero == 0)
assert(swig_type(v.zero) == "number")
assert(v.one == 1)
assert(swig_type(v.one) == "number")

v.zero = 42
assert(v.zero == 42)

assert(v.fa == 1)
assert(v.da == 1)
assert(swig_type(v.la) == "long double *") -- swig do not support long double

assert(v.fc == 1)
assert(v.dc == 1)
assert(swig_type(v.lc) == "long double *") -- swig do not support long double

assert(v.wstring_lit_len1 == 6)
assert(v.wstring_lit_len2 == 6)
assert(v.pi_approx == (355.0 / 133.0)) -- Lua uses same C++ double math!
assert(v.Bar ==  "foo")
assert(v.Foo ==  "bar")
assert(v.Bar2 == "foo")
assert(v.Foo2 == "bar")
assert(v.Bar3)
assert(v.Foo3 == 1)
assert(v.CAST_HAD_WRONG_PRECEDENCE1 == 2)
assert(v.CAST_HAD_WRONG_PRECEDENCE2 == 2)
assert(v.CAST_HAD_WRONG_PRECEDENCE3 == -1)
assert(v.CAST_HAD_WRONG_PRECEDENCE4 == 3)
-- NOEXCEPT_FUNC TODO should be pointer to func()
