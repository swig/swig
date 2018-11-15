# file: runme.py

import example

# ----- Object creation -----

# Print out the value of some enums
print "*** color ***"
print "    RED    =", example.RED
print "    BLUE   =", example.BLUE
print "    GREEN  =", example.GREEN

print "\n*** Foo::speed ***"
print "    Foo_IMPULSE   =", example.Foo.IMPULSE
print "    Foo_WARP      =", example.Foo.WARP
print "    Foo_LUDICROUS =", example.Foo.LUDICROUS

print "\nTesting use of enums with functions\n"

example.enum_test(example.RED, example.Foo.IMPULSE)
example.enum_test(example.BLUE, example.Foo.WARP)
example.enum_test(example.GREEN, example.Foo.LUDICROUS)
example.enum_test(1234, 5678)

print "\nTesting use of enum with class method"
f = example.Foo()

f.enum_test(example.Foo.IMPULSE)
f.enum_test(example.Foo.WARP)
f.enum_test(example.Foo.LUDICROUS)

print "\nTesting integer typed enum in class constructor with int overload"
n = example.SECOND
b = example.Bar(f,1,n)
print("The following should say 'SECOND' and 'numeric USED'")
b.enum_test()
b2 = example.Bar(f,2,155)
print("The following should say 'THIRD'(defaulted) and 'numeric NOT USED'")
b2.enum_test()
b2.enum_test_cpp();
