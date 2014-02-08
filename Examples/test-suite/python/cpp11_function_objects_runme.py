import cpp11_function_objects
import sys

t = cpp11_function_objects.Test()
if t.value != 0:
	raise RuntimeError("Runtime cpp11_function_objects failed. t.value should be 0, but is " + str(t.value))

t(1,2) # adds numbers and sets value

if t.value != 3:
	raise RuntimeError("Runtime cpp11_function_objects failed. t.value not changed - should be 3, but is " + str(t.value))
 
