require("import")	-- the import fn
import("static_const_member_2")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

cs = static_const_member_2

t = cs.Test_int()

assert( cs.CavityPackFlags.forward_field == 1 );
assert( cs.CavityPackFlags.backward_field == 2 );
assert( cs.Test_int.forward_field == 1 );
assert( cs.Test_int.backward_field == 2 );

a = cs.Test_int.LeftIndex
a = cs.Test_int.RightIndex

assert( cs.Test_int.current_profile == 4 );

assert( cs.Foo.BAR.val == 1 );
assert( cs.Foo.BAZ.val == 2 );
