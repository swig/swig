require("cpp11_final_directors")

local b = cpp11_final_directors.Derived()
assert(b:meth() == 2) -- Original Derived::meth()

swig_override(b, 'meth', function (self)
  return 3
end)

assert(b:meth() == 3) -- Override Lua method

swig_override(b, 'finalinderived', function (self)
  return 98
end)
swig_override(b, 'finalinderived2', function (self)
  return 99
end)

-- meth is overridable, so C++ calls into Lua for it
assert(cpp11_final_directors.call_meth(b) == 3)

-- The final overrides are not directed, so C++ keeps its own implementations
assert(cpp11_final_directors.call_finalinderived(b) == 11)
assert(cpp11_final_directors.call_finalinderived2(b) == 21)
