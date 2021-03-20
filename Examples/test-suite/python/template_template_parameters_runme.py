from template_template_parameters import *

# Test second part
floatTestStruct = FloatTestStruct()
floatContainer2 = floatTestStruct.x
floatContainer2.x = 8.1
intTestStruct = IntTestStruct()
intContainer1 = intTestStruct.x
intContainer1.x = 91
if intContainer1.x!=91:
    raise RuntimeError("Failed")
if intTestStruct.x.x!=91:
    raise RuntimeError("Failed")

