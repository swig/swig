require("import") -- the import fn
import("director_minimal") -- import code

function my_run(self)
  return true
end

local c = director_minimal.Minimal()
swig_override(c, "run", my_run)
assert(c:get())
