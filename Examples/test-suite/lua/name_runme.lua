require("name")

assert(pcall(function() name.foo_2() end))
assert(name.bar_2 == 17)
assert(name.Baz_2 == 47)
