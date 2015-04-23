# file: runme.py

import example

# First create some objects using the pointer library.
print "Testing the pointer library"
a = example.new_intp()
b = example.new_intp()
c = example.new_intp()
example.intp_assign(a, 37)
example.intp_assign(b, 42)

print "     a =", a
print "     b =", b
print "     c =", c

# Call the add() function with some pointers
example.add(a, b, c)

# Now get the result
r = example.intp_value(c)
print "     37 + 42 =", r

# Clean up the pointers
example.delete_intp(a)
example.delete_intp(b)
example.delete_intp(c)

# Now try the typemap library
# This should be much easier. Now how it is no longer
# necessary to manufacture pointers.

print "Trying the typemap library"
r = example.sub(37, 42)
print "     37 - 42 =", r

# Now try the version with multiple return values

print "Testing multiple return values"
q, r = example.divide(42, 37)
print "     42/37 = %d remainder %d" % (q, r)
