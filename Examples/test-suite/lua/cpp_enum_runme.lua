require("import")	-- the import fn
import("cpp_enum")	-- import code
ce=cpp_enum    -- renaming import

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

f = ce.Foo()

assert( f.hola == ce.Foo_Hello )
assert( f.hola == ce.Foo.Hello )

f.hola = ce.Foo.Hi

assert( f.hola == ce.Foo_Hi )
assert( f.hola == ce.Foo.Hi )
