require("import")	-- the import fn
import("char_binary_rev_len")	-- import lib
v = char_binary_rev_len

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

t = v.Test()
assert(t:strlen("hile") == 4, "bad multi-arg typemap 1");
assert(t:strlen("hil\0") == 4, "bad multi-arg typemap 2");

t2 = v.Test("hile")
assert(t2:getisize() == 4, "bad multi-arg typemap 3");
assert(t2:strlen("hil\0a") == 5, "bad multi-arg typemap 4");
