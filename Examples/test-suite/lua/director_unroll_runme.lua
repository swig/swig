require("import") -- the import fn
import("director_unroll") -- import lib

local a = director_unroll.Foo()
function ping(self)
    return "MyFoo::ping()"
end
swig_override(a, 'ping', ping)
local b = director_unroll.Bar()
b:set(a)
local c = b:get()

assert(a == c)
assert(c:ping() == "MyFoo::ping()")
