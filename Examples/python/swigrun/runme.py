# file: runme.py

# This file illustrates the cross language polymorphism using directors.

import example 


# CEO class, which overrides Employee::getPosition().

class CEO(example.Manager):
	def __init__(self, name):
		example.Manager.__init__(self, name)
	def getPosition(self):
		return "CEO"
	def __del__(self):
		print "CEO.__del__(),", self.getName()
		# for shadow class extensions that are not "disowned" and
		# define a __del__ method, it is very important to call the 
		# base class __del__.  otherwise the c++ objects will never
		# be deleted.
		example.Manager.__del__(self)




e = CEO("Alice")
m = example.convert_to_Manager(e)
print m
