require("director_exception_catches")

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
assert(not ret and msg == 'object exception:Swig::DirectorException')
