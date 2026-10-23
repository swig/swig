require("director_extend")

local m = director_extend.SpObject()
swig_override(m, 'getFoo', function(self)
    return 123
    end)

assert(m:dummy() == 666)
assert(m:dummy() == 666)
