require("import")
require("li_carrays_cpp")
lc=li_carrays_cpp
catch_undef_globs() -- catch "undefined" global variables

-- Testing for %array_functions(int,intArray)
ary = lc.new_intArray(2)
lc.intArray_setitem(ary, 0, 0)
lc.intArray_setitem(ary, 1, 1)
assert(lc.intArray_getitem(ary, 0)==0)
assert(lc.intArray_getitem(ary, 1)==1)
lc.delete_intArray(ary)

-- Testing for %array_class(double, doubleArray)
d = lc.doubleArray(10)
d[0] = 7
d[5] = d[0] + 3
assert(d[5] + d[0] == 17)
--print(d[5] + d[0])

ptr = d:cast()	-- to ptr
d2 = lc.doubleArray_frompointer(ptr) -- and back to array
assert(d2[5] + d2[0] == 17)
--print(d2[5] + d2[0])

