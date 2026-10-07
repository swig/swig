fc=require("funcptr_cpp")
catch_undef_globs() -- catch "undefined" global variables

assert(fc.addByValue(5,10) == 15)
-- These two won't work. Lua will successfully store the answer as userdata, but there is
-- no way of accessing the insides of userdata.
-- assert(fc.addByPointer(7, 9) == 16)
-- assert(fc.addByReference(8, 9) == 17)

assert(fc.call1(fc.ADD_BY_VALUE, 5, 10) == 15)
assert(fc.call2(fc.ADD_BY_POINTER, 7, 9) == 16)
assert(fc.call3(fc.ADD_BY_REFERENCE, 8, 9) == 17)
assert(fc.call1(fc.ADD_BY_VALUE_C, 2, 3) == 5)

assert(fc.callref1(fc.ADD_BY_VALUE, 1, 2) == 3)
assert(fc.callref2(fc.ADD_BY_VALUE, 2, 3) == 5)
assert(fc.callref1(fc.getAddByValueRef1(), 3, 4) == 7)
assert(fc.callref2(fc.getAddByValueRef2(), 4, 5) == 9)
assert(fc.AddByValueRefHolder(fc.ADD_BY_VALUE):call(5, 6) == 11)
