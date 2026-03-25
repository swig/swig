require("import")                -- the import fn
import("cpp11_shared_ptr_const") -- import lib

assert(cpp11_shared_ptr_const.single_foo(cpp11_shared_ptr_const.Foo(1)):get_m() == 1)
assert(cpp11_shared_ptr_const.const_single_foo(cpp11_shared_ptr_const.Foo(7)):get_m() == 7)
assert(cpp11_shared_ptr_const.foo_vec(cpp11_shared_ptr_const.Foo(7))[0]:get_m() == 7)
assert(cpp11_shared_ptr_const.const_foo_vec(cpp11_shared_ptr_const.Foo(8))[0]:get_m() == 8)
