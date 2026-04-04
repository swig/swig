local v=require("overload_return_type")

local b = v.B()
assert(b:foo(1) == 0)
assert(swig_type(b:foo("test")) == "A *")
assert(v.foo() == 1, "overload_return_type::foo() should be 1")
assert(v.bar() == 1, "overload_return_type::bar() should be 1")
