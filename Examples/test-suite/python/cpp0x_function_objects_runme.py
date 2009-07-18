import cpp0x_function_objects
import sys

t = cpp0x_function_objects.Test()
if t.value != 0:
	raise RuntimeError,"Runtime cpp0x_function_objects failed. t.value should be 0, but is", t.value

t(1,2) # sets value

if t.value != 10:
	raise RuntimeError,"Runtime cpp0x_function_objects failed. t.value not changed - should be 10, but is", t.value
 
