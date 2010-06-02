require("import")	-- the import fn
import("li_carrays")	-- import code

-- moving to global
for k,v in pairs(li_carrays) do _G[k]=v end

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- Testing for %array_functions(int,intArray)
ary = new_intArray(2)
intArray_setitem(ary, 0, 0)
intArray_setitem(ary, 1, 1)
assert(intArray_getitem(ary, 0)==0)
assert(intArray_getitem(ary, 1)==1)
delete_intArray(ary)

-- Testing for %array_class(double, doubleArray)
d = doubleArray(10)
d[0] = 7
d[5] = d[0] + 3
assert(d[5] + d[0] == 17)
--print(d[5] + d[0])

ptr = d:cast()	-- to ptr
d2 = doubleArray_frompointer(ptr) -- and back to array
assert(d2[5] + d2[0] == 17)
--print(d2[5] + d2[0])

