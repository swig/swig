local v=require("template_template_parameters")

-- Test part 1
local listBool = v.ListFastBool()
listBool.item = true
local x_boolean = listBool.allotype
assert(listBool.item)

local listDouble = v.ListDefaultDouble()
listDouble.item = 10.2
local x_double = listDouble.allotype
assert(listDouble.item == 10.2)

-- Test part 2
local floatTestStruct = v.FloatTestStruct()
local floatContainer2 = floatTestStruct.x
floatContainer2.x = 8.1
local intTestStruct = v.IntTestStruct()
local intContainer1 = intTestStruct.x
intContainer1.x = 91
assert(intContainer1.x == 91)
assert(intTestStruct.x.x == 91)
local intTestStructReturned = v.TestStructContainer1Method(intTestStruct)
assert(intTestStructReturned.x.x == 101)
