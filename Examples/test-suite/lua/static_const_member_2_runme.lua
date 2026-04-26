require("import")
require("static_const_member_2")
scm=static_const_member_2
catch_undef_globs() -- catch "undefined" global variables

assert(scm.CavityPackFlags.forward_field == 1)
assert(scm.CavityPackFlags.backward_field == 2)
assert(scm.CavityPackFlags.cavity_flags == 3)

assert(scm.CavityPackFlags.flags == 0)
scm.CavityPackFlags.flags = 91
assert(scm.CavityPackFlags.flags == 91)
assert(scm.CavityPackFlags_flags == 91) -- old style bindings

assert(scm.CavityPackFlags.reftest == 42)

assert(scm.Test_int.LeftIndex ~= nil)
assert(scm.Test_int.current_profile == 4)

assert(scm.Foo.BAR.val == 1)
assert(scm.Foo.BAZ.val == 2)

assert(scm.Foo_BAR.val == 1)
assert(scm.Foo_BAZ.val == 2)

scm.Foo.BAR.val = 4
scm.Foo.BAZ.val = 5

assert(scm.Foo.BAR.val == 4)
assert(scm.Foo.BAZ.val == 5)

assert(scm.Foo_BAR.val == 4)
assert(scm.Foo_BAZ.val == 5)
