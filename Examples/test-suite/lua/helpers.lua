-- The following global functions are available for all tests in the test-suite
function catch_undef_globs() -- catch "undefined" global variables
-- use _G rather than _ENV, as _ENV is Lua 5.2 and later only; both name the same table here
setmetatable(_G, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})
end
function require_to_globs(name)
local module = require(name)
for k,v in pairs(module) do _G[k]=v end -- move to global
return module
end
function cmp_flt(x,y,d) -- compare float numbers
if type(d) == "number" then
return math.abs(x-y) < d end
return math.abs(x-y) < 0.001
end
