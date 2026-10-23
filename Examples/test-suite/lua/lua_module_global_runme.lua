-- complementary test of 'lua_no_module_global'
-- Ensure that using swig without the '-nomoduleglobal' option
-- does put module into globals

-- Initially the package should not be loaded
assert(package.loaded["lua_module_global"] == nil)

-- Load the module to local variable!
-- The module also loaded to 'lua_module_global', a global variable
local the_module = require("lua_module_global")

assert(the_module ~= nil)
assert(the_module.hi_mom ~= nil)
assert(the_module.hi_mom() == "hi mom!")

assert(lua_module_global ~= nil)
assert(lua_module_global.hi_mom ~= nil)
assert(lua_module_global.hi_mom() == "hi mom!")

assert(the_module == lua_module_global)
assert(the_module.hi_mom == lua_module_global.hi_mom)

-- It should be identical to global module variable
-- the -nomoduleglobal swig option.
assert(_G["lua_module_global"] == the_module)
assert(_G["lua_module_global"] == lua_module_global)
assert(lua_module_global == the_module)

-- And also to loaded package
assert(package.loaded["lua_module_global"] == the_module)
assert(package.loaded["lua_module_global"] == lua_module_global)
assert(package.loaded["lua_module_global"].hi_mom() == "hi mom!")
