require("class_ignore")

local a = class_ignore.Bar()
assert(a ~= nil)

-- Even though we didn't wrap the Foo class, this call
-- to do_blah() should succeed.
assert(class_ignore.do_blah(a) == "Bar::blah")
assert(a:blah() == "Bar::blah")
