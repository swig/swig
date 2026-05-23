require("import")	-- the import fn
import("director_stl")	-- import lib

local a = director_stl.Foo()
swig_derive(a, {
  ping = function(self, s)
    return "MyFoo::ping():" .. s
  end,
  pident = function(self, arg)
    return arg
  end,
  vident = function(self, v)
    return v
  end,
  vidents = function(self, v)
    return v
  end,
  vsecond = function(self, v1, v2)
    return v2
  end
})

-- Test tping (calls virtual ping through C++)
local r1 = a:tping("hello")
assert(r1 == "MyFoo::ping():hello", "bad tping: " .. r1)

-- Test tpong (calls pong which calls ping internally)
local r2 = a:tpong("hello")
assert(r2 == "Foo::pong:hello:MyFoo::ping():hello", "bad tpong: " .. r2)
