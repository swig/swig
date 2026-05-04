require("import")
require("cpp_enum")
ce=cpp_enum
catch_undef_globs() -- catch "undefined" global variables

assert(ce.ENUM_ONE ~= nil)
assert(ce.ENUM_TWO ~= nil)

-- Enums inside classes
assert(ce.Foo.Hi == 0)
assert(ce.Foo.Hello == 1)
-- old-style bindings
assert(ce.Foo_Hi == 0)
assert(ce.Foo_Hello == 1)

assert(ce.Hi == 0)
assert(ce.Hello == 1)
