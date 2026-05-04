require("import")
require("template_static")
ts=template_static
catch_undef_globs() -- catch "undefined" global variables

assert(ts.foo_i.test == 0)
ts.foo_i.test = 42
assert(ts.foo_i.test == 42)
assert(ts.foo_i_test == 42)
ts.foo_i_test = 57
assert(ts.foo_i.test == 57)
assert(ts.foo_i_test == 57)
assert(ts.foo_d.test == 0)

assert(ts.Foo.bar_double(4) == 1.0)
assert(ts.Foo_bar_double(4) == 1.0)
