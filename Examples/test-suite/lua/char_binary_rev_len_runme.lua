require("import")
require("char_binary_rev_len")
v = char_binary_rev_len
catch_undef_globs() -- catch "undefined" global variables

t = v.Test()
assert(t:strlen("hile") == 4, "bad multi-arg typemap 1")
assert(t:strlen("hil\0") == 4, "bad multi-arg typemap 2")

t2 = v.Test("hile")
assert(t2:getisize() == 4, "bad multi-arg typemap 3")
assert(t2:strlen("hil\0a") == 5, "bad multi-arg typemap 4")
