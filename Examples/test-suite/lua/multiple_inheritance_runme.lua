require("multiple_inheritance")

local fooBar = multiple_inheritance.FooBar()
assert(fooBar:foo() == 2, "test1")
assert(fooBar:bar() == 1, "test2")
assert(fooBar:fooBar() == 3, "test3")
