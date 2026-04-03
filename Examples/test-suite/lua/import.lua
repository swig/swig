-- left over from old Lua versions.
-- new scripts should use 'require' directly!
function import(name) require(name) end
-- catch "undefined" global variables
function catch_undef_globs()
setmetatable(_ENV, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})
end
function move_to_globs(module)
for k,v in pairs(module) do _G[k]=v end -- move to global
end
function import_to_globs(name)
local module = require(name)
move_to_globs(module)
end
