require("exception_classname")

local a = exception_classname.Exception()
assert(a:testfunc() == 42, "Not 42!")
