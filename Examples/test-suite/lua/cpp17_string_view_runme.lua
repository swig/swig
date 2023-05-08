require("import")	-- the import fn
import("cpp17_string_view")	-- import lib

for k,v in pairs(cpp17_string_view) do _G[k]=v end -- move to global

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- Checking expected use of %typemap(in) std::string_view {}
test_value("Fee")

-- Checking expected result of %typemap(out) std::string_view {}
s=test_value("Fi")
assert(type(s)=="string" and s =="Fi")

-- Checking expected use of %typemap(in) const std::string_view & {}
test_const_reference("Fo")

-- Checking expected result of %typemap(out) const std::string_view& {}
s=test_const_reference("Fum")
assert(type(s)=="string" and s =="Fum")

-- Input and output typemaps for pointers and non-const references to
-- std::string_view are *not* supported; the following tests confirm
-- that none of these cases are slipping through.

stringPtr = test_pointer_out()

test_pointer(stringPtr)

stringPtr = test_const_pointer_out()

test_const_pointer(stringPtr)

stringPtr = test_reference_out()

test_reference(stringPtr)

-- Global variables
assert(cpp17_string_view.ConstGlobalString=="const global string")

-- Member variables
myStructure = Structure()
assert(myStructure.ConstMemberString=="const member string")

assert(Structure.ConstStaticMemberString=="const static member string")

test_const_reference_returning_void("foo")
