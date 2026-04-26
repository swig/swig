require("director_nspace_director_name_collision")

-- Create a derived classes
local MyAFoo = {}
function MyAFoo:new()
    -- Inherit TopLevel::A::Foo
    local parent = director_nspace_director_name_collision.TopLevel.A.Foo
    self.__index = self
    setmetatable(self, { __index = parent })
	local obj = parent()
    swig_override(obj, "ping", function(self)
        return "director_nspace_director_name_collision.MyAFoo.ping()"
    end)
	return obj
end

local MyBFoo = {}
function MyBFoo:new()
    -- Inherit TopLevel::B::Foo
    local parent = director_nspace_director_name_collision.TopLevel.B.Foo
    self.__index = self
    setmetatable(self, { __index = parent })
	local obj = parent()
    swig_override(obj, "ping", function(self)
        return "director_nspace_director_name_collision.MyBFoo.ping()"
    end)
	return obj
end

local a = MyAFoo:new()
assert(a:ping() == "director_nspace_director_name_collision.MyAFoo.ping()")
local b = MyBFoo:new()
assert(b:ping() == "director_nspace_director_name_collision.MyBFoo.ping()")
