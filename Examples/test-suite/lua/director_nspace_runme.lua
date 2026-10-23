require("director_nspace")

-- Create a derived class
local MyBarFoo = {}
function MyBarFoo:new()
    local parent = director_nspace.TopLevel.Bar.Foo
    self.__index = self
    -- Inherit TopLevel::Bar::Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent!
    local pingFunc = function(self)
      return "director_nspace_MyBarFoo.ping()"
    end
	local obj = parent()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      ping = pingFunc,
      pong = function(self)
        return "director_nspace_MyBarFoo.pong()" .. pingFunc(self)
        -- self:ping() Lua call original C++ class method
      end,
      fooBar = function(obj)
        return obj:FooBarDo()
      end,
      makeFoo = function()
        return director_nspace.TopLevel.Bar.Foo()
      end,
      makeFooBar = function()
        return director_nspace.TopLevel.Bar.FooBar()
      end
    })
	return obj
end

local c = MyBarFoo:new()
assert(c:ping() == "director_nspace_MyBarFoo.ping()")
assert(c:pong() == "director_nspace_MyBarFoo.pong()director_nspace_MyBarFoo.ping()")
