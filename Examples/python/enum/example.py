# file: example.py

import example

# ----- Object creation -----

# Print out the value of some enums
print "*** color ***"
print "    RED    =", example.RED
print "    BLUE   =", example.BLUE
print "    GREEN  =", example.GREEN

print "\n*** Foo::speed ***"
print "    Foo_IMPULSE   =", example.Foo_IMPULSE
print "    Foo_WARP      =", example.Foo_WARP
print "    Foo_LUDICROUS =", example.Foo_LUDICROUS

print "\nTesting use of enums with functions\n"

example.enum_test(example.RED, example.Foo_IMPULSE)
example.enum_test(example.BLUE,  example.Foo_WARP)
example.enum_test(example.GREEN, example.Foo_LUDICROUS)
example.enum_test(1234,5678)

print "\nTesting use of enum with class method"
f = example.new_Foo()

example.Foo_enum_test(f,example.Foo_IMPULSE)
example.Foo_enum_test(f,example.Foo_WARP)
example.Foo_enum_test(f,example.Foo_LUDICROUS)
