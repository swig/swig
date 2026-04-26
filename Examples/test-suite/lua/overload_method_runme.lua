require("overload_method")

local b = overload_method.Base()
assert(b:method() == 42)
assert(b:overloaded_method() == 42)
b:overloaded_method(5)
assert(b:overloaded_method() == 5)
assert(b:method() == 5)
