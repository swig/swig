require("import")	-- the import fn
import("argcargvtest")	-- import lib
v = argcargvtest

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

largs = {"hi", "hola", "hello"}
assert(v.mainc(largs) == 3, "bad main typemap")

targs = {"hi", "hola"}
assert(v.mainv(targs, 0) == "hi", "bad main typemap")
assert(v.mainv(targs, 1) == "hola", "bad main typemap")
assert(v.mainv(targs, 2) == "<<NULL>>", "bad main typemap")

errorVal = 0
function try()
    mainv("hello", 1)
    errorVal = 1
end
assert(not pcall(try) and errorVal == 0, "bad main typemap")

v.initializeApp(largs)

-- Check that an empty array works.
empty_args = {}
assert(v.mainc(empty_args) == 0, "bad main typemap")
assert(v.mainv(empty_args, 0) == "<<NULL>>", "bad main typemap")

-- Check that empty strings are handled.
empty_string = {"hello", "", "world"}
assert(v.mainc(empty_string) == 3, "bad main typemap")
assert(v.mainv(empty_string, 0) == "hello", "bad main typemap")
assert(v.mainv(empty_string, 1) == "", "bad main typemap")
assert(v.mainv(empty_string, 2) == "world", "bad main typemap")
assert(v.mainv(empty_string, 3) == "<<NULL>>", "bad main typemap")
