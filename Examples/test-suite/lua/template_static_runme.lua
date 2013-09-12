require("import")	-- the import fn
import("template_static")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

ts = template_static

assert( ts.foo_i.test == 0 );
ts.foo_i.test = 5;
assert( ts.foo_i.test == 5 );
assert( ts.foo_i_test == 5 );

assert( ts.foo_d.test == 0 );

obj = ts.foo_i()

assert( ts.Foo_bar_double(5) == 1.0 )
assert( ts.Foo.bar_double(5) == 1.0 )
