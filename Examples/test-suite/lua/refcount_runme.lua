require("import")
require("refcount")
r=refcount
catch_undef_globs() -- catch "undefined" global variables

a = r.A()
assert(a:ref_count() == 1)

b1 = r.B(a)
assert(a:ref_count() == 2)

b2 = r.B.create(a)
assert(a:ref_count() == 3)

b3 = b2:cloner()
assert(a:ref_count() == 4)

rca = b1:get_rca() -- RCPtr<A> is not wrapped
assert(a:ref_count() == 5)

b4 = r.global_create(a)
assert(a:ref_count() == 6)
