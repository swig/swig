require("import") -- the import fn
import("director_ignore") -- import lib

local a = director_ignore.DIgnores()
function PublicMethod1(self)
    return 18.75
end
swig_override(a, 'PublicMethod1', PublicMethod1)
assert(a:Triple(5) == 15)

local b = director_ignore.DAbstractIgnores()
assert(b:Quadruple(5) == 20)
