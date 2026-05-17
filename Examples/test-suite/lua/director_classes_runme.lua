require("director_classes")

-- Create a derived classes
local luaDerived = {}
function luaDerived:new(v)
    local parent = director_classes.Base
    self.__index = self
    -- Inherit Foo
    setmetatable(self, { __index = parent })
    -- Inside swig_derive() we can only call the partent methods!
	local obj = parent(v)
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
      Val = function(self, x)
        return x
      end,
      Ref = function(self, x)
        return x
      end,
      Ptr = function(self, x)
        return x
      end,
      ConstPtr = function(self, x)
        return x
      end,
      ConstPtrRef = function(self, x)
        return x
      end,
      FullyOverloaded = function(self, x)
        if type(x) == "number" then
          return "luaDerived::FullyOverloaded(int)"
        end
        return "luaDerived::FullyOverloaded(bool)"
      end,
      SemiOverloaded = function(self, x)
        if type(x) == "number" then
          return "luaDerived::SemiOverloaded(int)"
        end
        -- Lua Inherit class can not call base class method
        return "Base::SemiOverloaded(bool)"
      end,
      DefaultParms = function(self, x, y)
        if y == 1.125 then
          return "luaDerived::DefaultParms(int)"
        end
        return "luaDerived::DefaultParms(int, double)"
      end
    })
    return obj
end

function makeCalls(caller, base, name)
  caller:set(base)
  dh = director_classes.DoubleHolder(444.555)
  assert(caller:ValCall(dh).val == dh.val, "Val")
  assert(caller:RefCall(dh).val == dh.val, "Ref")
  assert(caller:PtrCall(dh).val == dh.val, "Ptr")
  assert(caller:ConstPtrCall(dh).val == dh.val, "ConstPtr")
  assert(caller:ConstPtrRefCall(dh).val == dh.val, "ConstPtrRef")
  assert(caller:FullyOverloadedCall(1) == name .. "::FullyOverloaded(int)", "FullyOverloaded(int)")
  assert(caller:FullyOverloadedCall(false) == name .. "::FullyOverloaded(bool)", "FullyOverloaded(bool)")
  assert(caller:SemiOverloadedCall(-678) == name .. "::SemiOverloaded(int)", "SemiOverloaded(int)")
  assert(caller:SemiOverloadedCall(false) == "Base::SemiOverloaded(bool)", "SemiOverloaded(bool)")
  assert(caller:DefaultParmsCall(10, 2.2) == name .. "::DefaultParms(int, double)", "DefaultParms(int, double)")
  assert(caller:DefaultParmsCall(10) == name .. "::DefaultParms(int)", "DefaultParms(int)")
  caller:reset()
end

caller = director_classes.Caller()
makeCalls(caller, director_classes.Base(100), "Base")
makeCalls(caller, director_classes.Derived(200), "Derived")
makeCalls(caller, luaDerived:new(300), "luaDerived", true)
