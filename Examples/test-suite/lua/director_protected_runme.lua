require("import")	-- the import fn
import("director_protected")	-- import lib

-- Create test objects
local b = director_protected.Bar()
local f = b:create()

-- FooBar: overrides ping
local fb = director_protected.Bar()
swig_override(fb, 'ping', function(self)
  return "FooBar::ping();"
end)

-- FooBar2: overrides ping and pang
local fb2 = director_protected.Bar()
swig_derive(fb2, {
  ping = function(self)
    return "FooBar2::ping();"
  end,
  pang = function(self)
    return "FooBar2::pang();"
  end
})

-- FooBar3: overrides cheer
local fb3 = director_protected.Bar()
swig_override(fb3, 'cheer', function(self)
  return "FooBar3::cheer();"
end)

-- Test overridden used() calls
assert(fb:used() == "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();",
  "bad FooBar::used: " .. fb:used())
assert(fb2:used() == "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();",
  "bad FooBar2::used: " .. fb2:used())

-- Test pong() calls
assert(b:pong() == "Bar::pong();Foo::pong();Bar::ping();",
  "bad Bar::pong: " .. b:pong())
assert(f:pong() == "Bar::pong();Foo::pong();Bar::ping();",
  "bad Foo::pong: " .. f:pong())
assert(fb:pong() == "Bar::pong();Foo::pong();FooBar::ping();",
  "bad FooBar::pong: " .. fb:pong())

-- Test cheer override
assert(fb3:cheer() == "FooBar3::cheer();",
  "bad fb3::cheer: " .. fb3:cheer())

-- Test callping/callcheer (call protected methods internally from C++)
assert(fb2:callping() == "FooBar2::ping();",
  "bad fb2:callping: " .. fb2:callping())
assert(fb2:callcheer() == "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();",
  "bad fb2:callcheer: " .. fb2:callcheer())
assert(fb3:callping() == "Bar::ping();",
  "bad fb3:callping: " .. fb3:callping())
assert(fb3:callcheer() == "FooBar3::cheer();",
  "bad fb3:callcheer: " .. fb3:callcheer())

-- Note: In Lua, director objects CAN call protected methods (they go through the
-- SwigDirector public accessor). This differs from Python where protected access
-- is additionally restricted via swig_get_inner(). This is by design.
-- Director objects (b, fb, fb2, fb3) can call protected methods:
assert(b:ping() == "Bar::ping();", "bad b:ping")
assert(b:cheer() == "Foo::pang();Bar::pong();Foo::pong();Bar::ping();", "bad b:cheer")

-- Non-director objects (f, returned by Bar::create() which does new Bar() in C++)
-- CANNOT call protected methods - the darg null check catches this:
local ret, msg = pcall(function() f:ping() end)
assert(not ret, "f:ping() should fail - f is not a director")

ret, msg = pcall(function() f:pang() end)
assert(not ret, "f:pang() should fail - f is not a director")

ret, msg = pcall(function() f:cheer() end)
assert(not ret, "f:cheer() should fail - f is not a director")
