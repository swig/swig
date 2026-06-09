require("cpp11_director_enums")

-- Create a derived classes
local MyEnumsCB = {}
function MyEnumsCB:new()
    local parent = cpp11_director_enums.Cpp11DirectorEnumsCallback
    self.__index = self
    -- Inherit Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
	local obj = parent()
    local color = cpp11_director_enums.Color_Red
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      f = function(self, c)
        if c == cpp11_director_enums.Color_Red then
            return cpp11_director_enums.Color_Green
        end
        return c
      end,
      g = function(self, c)
        -- TODO pass a reference to Color
        return cpp11_director_enums.Color_Blue
      end
    })
    return obj
end

local m = MyEnumsCB:new()

assert(m:f(cpp11_director_enums.Color_Red) == cpp11_director_enums.Color_Green)
assert(m:f(cpp11_director_enums.Color_Blue) == cpp11_director_enums.Color_Blue)
--[[
TODO pass reference of Color
assert(m:g(cpp11_director_enums.Color_Blue) == cpp11_director_enums.Color_Red)
assert(m:g(cpp11_director_enums.Color_Green) == cpp11_director_enums.Color_Green)
]]
