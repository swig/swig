require("rname")

rname.foo_i(10)
rname.foo_d(10)
rname.foo_s(10)
rname.foo(10)

local bar = rname.Bar()
bar:foo_i(10)
bar:foo_d(10)
bar:foo(10)
bar:foo_u(10)

local base = rname.RenamedBase()
base:fn1(base, base, base)
assert(base:newname(10) == "Base", "base.newname")

local derived = rname.RenamedDerived()
derived:Xfunc(base, base, base)
assert(derived:newname(10) == "Derived", "derived.newname")
