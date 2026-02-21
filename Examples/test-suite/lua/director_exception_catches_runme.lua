require("import") -- the import fn
import("director_exception_catches") -- import lib

local b = director_exception_catches.BaseClass()
function description(self)
    error("Testing exception thrown in BaseClass.description")
end
swig_override(b, 'description', description)

function run_catch()
    local s = director_exception_catches.BaseClass.call_description(b)
    error("Should not happen")
end
local ret, msg = pcall(run_catch)
assert(not ret)
assert(msg == 'object exception:Swig::DirectorException')
