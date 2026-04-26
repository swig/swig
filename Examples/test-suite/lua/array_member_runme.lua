require("import")
require("array_member")
am = array_member
catch_undef_globs() -- catch "undefined" global variables

assert(am.get_value(am.global_data,0) == 0)
assert(am.get_value(am.global_data,7) == 7)

foo = am.Foo()
foo.data = am.global_data
assert(am.get_value(foo.data,0) == 0)

for i = 0, 7 do
  assert(am.get_value(foo.data,i) == am.get_value(am.global_data,i))
end


for i = 0, 7 do
  am.set_value(am.global_data,i,-i)
end

am.global_data = foo.data

for i = 0, 7 do
  assert(am.get_value(foo.data,i) == am.get_value(am.global_data,i))
end
