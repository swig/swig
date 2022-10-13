require("import")	-- the import fn
import("exception_memory_leak")	-- import code
eml=exception_memory_leak --alias

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

a = eml.Foo()
assert(eml.Foo_get_count() == 1)
b = eml.Foo()
assert(eml.Foo_get_count() == 2)

-- Normal behaviour
eml.trigger_internal_swig_exception("no problem", a)
assert(eml.Foo_get_count() == 2)
assert(eml.Foo_get_freearg_count() == 1)

-- SWIG exception triggered and handled (return new object case)
ok,ex=pcall(eml.trigger_internal_swig_exception, "null", b)
assert(ok==false)
assert(eml.Foo_get_count() == 2)
assert(eml.Foo_get_freearg_count() == 2)

-- SWIG exception triggered and handled (return by value case).
ok,ex=pcall(eml.trigger_internal_swig_exception, "null")
assert(ok==false)
assert(eml.Foo_get_count() == 2)
