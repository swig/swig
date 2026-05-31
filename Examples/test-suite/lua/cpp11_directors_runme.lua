require("cpp11_directors")

-- Create a derived class of 'Foo'
local MyFoo = {}
function MyFoo:new()
    local parent = cpp11_directors.Foo
    self.__index = self
    -- Inherit Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
	local obj = parent()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      ping = function(self)
        return 1
      end,
      pong = function(self)
        return 2
      end,
      pang = function(self)
        return 3
      end,
      peng = function(self)
        return 4
      end,
      pung = function(self)
        return 5
      end
    })
    return obj
end

-- Create a derived class of 'MoveOnlyNode'
local MyMoveNode = {}
function MyMoveNode:new()
    local parent = cpp11_directors.MoveOnlyNode
    self.__index = self
    -- Inherit Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
	local obj = parent()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      rvalues_mo = function(self, o)
        -- print("MyMoveNode::rvalues_mo")
      end,
      rvalues_mo_overload = function(self, a, b, c)
        if type(a) == "number" then -- (int, double, MoveOnlyNode &&)
            -- print("MyMoveNode::rvalues_mo_overload(int, double, MoveOnlyNode &&)")
        else -- (MoveOnlyNode &&)
            -- print("MyMoveNode::rvalues_mo_overload(MoveOnlyNode &&)")
        end
      end,
      rvalues_using = function(self)
        -- print("MyMoveNode::rvalues_using2")
      end,
      rvalues_using2 = function(self)
        -- print("MyMoveNode::rvalues_using2")
      end
    })
    return obj
end


local f = MyFoo:new()
assert(f:ping() == 1)
assert(f:pong() == 2)
assert(f:pang() == 3)
assert(f:peng() == 4)
assert(f:pung() == 5)

local m = MyMoveNode:new()
-- m:rvalues_int(11) TODO convert to 'int&&'
local m2 = MyMoveNode:new()
m:rvalues_mo(m2)
local m2 = MyMoveNode:new()
m:rvalues_mo_overload(m2)
local m2 = MyMoveNode:new()
m:rvalues_mo_overload(1, 2.5, m2)
local m2 = MyMoveNode:new()
-- m:rvalues_using(2.5, m2) -- TODO convert to double&&
local m2 = MyMoveNode:new()
-- m:rvalues_using2(7.3, m2) -- TODO convert to double&&
