require("inherit")

local der = inherit.CDerived()
assert(der:Foo() == "CBase::Foo")
