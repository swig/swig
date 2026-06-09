local v=require("li_boost_shared_ptr_director")


-- Create a derived classes
local Derived = { return_none = false }
function Derived:new(flag)
    local parent = li_boost_shared_ptr_director.Base
    self.__index = self
    setmetatable(self, { __index = parent })
	local obj = parent()
    -- We can not add properties to userdata!
    -- But local variables remains in the same scope as the object!
    local return_none = flag
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      ret_c_shared_ptr = function(self)
        if return_none then
            return nil
        else
            return li_boost_shared_ptr_director.C()
        end
      end,
      ret_c_by_value = function(self)
        return li_boost_shared_ptr_director.C()
      end,
      take_c_by_value = function(self, c)
        return c:get_m()
      end,
      take_c_by_ref = function(self, c)
        return c:get_m()
      end,
      take_c_by_pointer = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -2
        end
      end,
      take_c_by_pointer_ref = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -3
        end
      end,
      take_c_shared_ptr_by_value = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -4
        end
      end,
      take_c_shared_ptr_by_ref = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -5
        end
      end,
      take_c_shared_ptr_by_pointer = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -6
        end
      end,
      take_c_shared_ptr_by_pointer_ref = function(self, c)
        if c ~= nil then
            return c:get_m()
        else
            return -7
        end
      end
    })
    return obj
end

local a = Derived:new(false)
local b = Derived:new(true)

assert(v.call_ret_c_shared_ptr(a) == 1)
assert(v.call_ret_c_shared_ptr(b) == -1)
assert(v.call_ret_c_by_value(a) == 1)
assert(v.call_take_c_by_value(a) == 5)
assert(v.call_take_c_by_ref(a) == 6)
assert(v.call_take_c_by_pointer(a) == 7)
assert(v.call_take_c_by_pointer_ref(a) == 8)
assert(v.call_take_c_shared_ptr_by_value(a) == 9)
assert(v.call_take_c_shared_ptr_by_ref(a) == 10)
assert(v.call_take_c_shared_ptr_by_pointer(a) == 11)
assert(v.call_take_c_shared_ptr_by_pointer_ref(a) == 12)
assert(v.call_take_c_by_pointer_with_null(a) == -2)
assert(v.call_take_c_by_pointer_ref_with_null(a) == -3)
assert(v.call_take_c_shared_ptr_by_value_with_null(a) == -4)
assert(v.call_take_c_shared_ptr_by_ref_with_null(a) == -5)
assert(v.call_take_c_shared_ptr_by_pointer_with_null(a) == -6)
assert(v.call_take_c_shared_ptr_by_pointer_ref_with_null(a) == -7)
