require("import") -- the import fn
import("director_using_member_scopes") -- import lib

local nwt = director_using_member_scopes.NativeWindowType()

local a = director_using_member_scopes.ApplicationContextSDL()
swig_override(a, 'setWindowGrab', function(self, win, grab)
    return 100
end)
assert(director_using_member_scopes.ApplicationContextBase.call_setWindowGrab(a, nwt, true) == 100)
assert(director_using_member_scopes.ApplicationContextSDL.call_setWindowGrab(a, nwt, true) == 100)

local b = director_using_member_scopes.ACSDL()
swig_override(b, 'setWindowGrab', function(self, a, b)
  -- Lua functions do not depends argument parameter types
  -- But we can check the type inside
  if type(a) == 'string' then
     return 200
  end
  return 100
  end)
assert(director_using_member_scopes.ACB.call_setWindowGrab(b, nwt, true) == 100)
assert(director_using_member_scopes.ACB.call_setWindowGrab(b, "hi", 0) == 200)
assert(director_using_member_scopes.ACSDL.call_setWindowGrab(b, nwt, true) == 100)
assert(director_using_member_scopes.ACSDL.call_setWindowGrab(b, "hi", 0) == 200)
