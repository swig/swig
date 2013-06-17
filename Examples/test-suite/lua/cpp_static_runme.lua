require("import")	-- the import fn
import("cpp_static")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

cs = cpp_static

cs.StaticMemberTest.static_int = 5
assert( cs.StaticMemberTest.static_int == 5 );
assert( cs.StaticMemberTest_static_int == 5 );

cs.StaticMemberTest_static_int = 6;
assert( cs.StaticMemberTest.static_int == 6 );
assert( cs.StaticMemberTest_static_int == 6 );

cs.StaticFunctionTest.static_func()
cs.StaticFunctionTest_static_func()

cs.StaticFunctionTest.static_func_2(5)
cs.StaticFunctionTest_static_func_2(5)
