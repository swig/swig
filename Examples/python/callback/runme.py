# file: runme.py

# This file illustrates the cross language polymorphism using directors.

import example 


# CEO class, which overrides Employee::getPosition().

class PyCallback(example.Callback):
	def __init__(self):
		example.Callback.__init__(self)
	def run(self):
		print "PyCallback.run()"
	def __del__(self):
		print "PyCallback.__del__()"
		# for shadow class extensions that are not "disowned" and
		# define a __del__ method, it is very important to call the 
		# base class __del__.  otherwise the c++ objects will never
		# be deleted.
		example.Callback.__del__(self)


# Create an Caller instance

caller = example.Caller()

# Add a simple C++ callback (caller owns the callback, so
# we disown it first by clearing the .thisown flag).

print "Adding and calling a normal C++ callback"
print "----------------------------------------"

callback = example.Callback()
callback.thisown = 0
caller.setCallback(callback)
caller.call()
caller.delCallback();

print
print "Adding and calling a Python callback"
print "------------------------------------"

# Add a Python callback (caller owns the callback, so we
# disown it first by calling __disown__).

caller.setCallback(PyCallback().__disown__())
caller.call()
caller.delCallback()

print
print "Adding and calling another Python callback"
print "------------------------------------------"

# Lets do the same but use the weak reference this time.

callback = PyCallback().__disown__()
caller.setCallback(callback)
caller.call()
caller.delCallback()

# All done.

print
print "python exit"

