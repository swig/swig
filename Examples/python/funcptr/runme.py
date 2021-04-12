# file: runme.py

import example

a = 37
b = 42

# Now call our C function with a bunch of callbacks

print("Trying some C callback functions")
print("    a        = %s" % a)
print("    b        = %s" % b)
print("    ADD(a,b) = %s" % example.do_op(a, b, example.ADD))
print("    SUB(a,b) = %s" % example.do_op(a, b, example.SUB))
print("    MUL(a,b) = %s" % example.do_op(a, b, example.MUL))

print("Here is what the C callback function objects look like in Python")
print("    ADD      = %s" % example.ADD)
print("    SUB      = %s" % example.SUB)
print("    MUL      = %s" % example.MUL)
