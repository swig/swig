-- The following global functions are available for all tests in the test-suite
function catch_undef_globs() -- catch "undefined" global variables
setmetatable(_ENV, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})
end
function require_to_globs(name)
local module = require(name)
for k,v in pairs(module) do _G[k]=v end -- move to global
return module
end
