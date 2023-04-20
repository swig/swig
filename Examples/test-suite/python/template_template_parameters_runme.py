from template_template_parameters import *

# Test part 1
listBool = ListFastBool()
listBool.item = True
x_boolean = listBool.allotype
if listBool.item != True:
  raise RuntimeError("Failed")

listDouble = ListDefaultDouble()
listDouble.item = 10.2
x_double = listDouble.allotype
if listDouble.item != 10.2:
  raise RuntimeError("Failed")

# Test part 2
floatTestStruct = FloatTestStruct()
floatContainer2 = floatTestStruct.x
floatContainer2.x = 8.1
intTestStruct = IntTestStruct()
intContainer1 = intTestStruct.x
intContainer1.x = 91
if intContainer1.x != 91:
  raise RuntimeError("Failed")
if intTestStruct.x.x != 91:
  raise RuntimeError("Failed")
intTestStructReturned = TestStructContainer1Method(intTestStruct)
if intTestStructReturned.x.x != 101:
  raise RuntimeError("Failed")

# Test part 3
mfi99 = MyFootInt99()
mfi99 += mfi99 # __iadd__
