require("director_shared_ptr")

-- Create a derived classes
local MyFoo = {}
function MyFoo:new()
    local parent = director_shared_ptr.Foo
    self.__index = self
    -- Inherit Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
    local pingFunc = function(self)
      return "director_shared_ptr_MyBarFoo.ping()"
    end
	local obj = parent()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      ping = pingFunc,
      pong = function(self)
        return "director_shared_ptr_MyBarFoo.pong();" .. pingFunc(self)
        -- self:ping() Lua call original C++ class method
      end,
      upcall = function(self, fooBarPtr)
        return "override;" .. fooBarPtr:FooBarDo()
      end,
      makeFoo = function(self)
        return director_shared_ptr.Foo()
      end
    })
    return obj
end

local MyFooDerived = {}
function MyFooDerived:new()
    local parent = director_shared_ptr.FooDerived
    self.__index = self
    -- Inherit FooDerived
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
    local pingFunc = function(self)
      return "director_shared_ptr_MyBarFooDerived.ping()"
    end
	local obj = parent()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      ping = pingFunc,
      pong = function(self)
        return "director_shared_ptr_MyBarFooDerived.pong();" .. pingFunc(self)
      end,
      upcall = function(self, fooBarPtr)
        return "overrideDerived;" .. fooBarPtr:FooBarDo()
      end,
      makeFoo = function(self)
        return director_shared_ptr.Foo()
      end
    })
    return obj
end

function check(got, expected)
  assert(got == expected, "got: " .. got .. " expected: " .. expected)
end

local fooBar = director_shared_ptr.FooBar()

local myBarFoo = MyFoo:new()
check(myBarFoo:ping(), "director_shared_ptr_MyBarFoo.ping()")
check(director_shared_ptr.Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()")
check(director_shared_ptr.Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()")

local myFoo = myBarFoo:makeFoo()
check(myFoo:pong(), "Foo::pong();Foo::ping()")
check(director_shared_ptr.Foo.callPong(myFoo), "Foo::pong();Foo::ping()")
check(myFoo:upcall(director_shared_ptr.FooBar()), "Bar::Foo2::Foo2Bar()")

local myFoo2 = director_shared_ptr.Foo():makeFoo()
check(myFoo2:pong(), "Foo::pong();Foo::ping()")
check(director_shared_ptr.Foo.callPong(myFoo2), "Foo::pong();Foo::ping()")
check(myFoo2:upcall(director_shared_ptr.FooBar()), "Bar::Foo2::Foo2Bar()")

local myBarFooDerived = MyFooDerived:new()
check(myBarFooDerived:ping(), "director_shared_ptr_MyBarFooDerived.ping()")
check(director_shared_ptr.FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()")
check(director_shared_ptr.FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()")
