require("constover")

assert(constover.test("test") == "test", "test")
assert(constover.test_pconst("test") == "test_pconst", "test_pconst")

local f = constover.Foo()
assert(f:test("test") == "test", "Foo::test")
assert(f:test_pconst("test") == "test_pconst", "Foo::test_pconst")
assert(f:test_constm("test") == "test_constmethod", "Foo::test_constm")
assert(f:test_pconstm("test") == "test_pconstmethod", "Foo::test_pconstm")
