# file: runme.py

import example 

# Create an object
v = example.Vector()

print "Setting some values"
# Set some values (using functions instead of attributes)
v.set_x(3.5)
v.set_y(4.0)
v.set_z(10.5)

# Get some values
print v
print v.x(), v.y(), v.z()

