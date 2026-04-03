require("cpp11_final_directors")

local b = cpp11_final_directors.Derived()
assert(b:meth() == 2) -- Original Derived::meth()

swig_override(b, 'meth', function (self)
  return 3
end)

assert(b:meth() == 3) -- Override Lua method
