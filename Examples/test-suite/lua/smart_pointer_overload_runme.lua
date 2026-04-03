require("import")
import_to_globs("smart_pointer_overload")

f = Foo()
b = Bar(f)

assert(f:test(3) == 1)
--assert(f:test(3.5) == 2)	-- won't work due to being unable to overloads
assert(f:test("hello") == 3)

assert(b:test(3) == 1)
--assert(b:test(3.5) == 2)	-- won't work due to being unable to overloads
assert(b:test("hello") == 3)
