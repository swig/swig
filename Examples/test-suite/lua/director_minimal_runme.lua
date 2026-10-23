require("director_minimal")

function my_run(self)
  return true
end

local c = director_minimal.Minimal()
swig_override(c, "run", my_run)
assert(c:get())
