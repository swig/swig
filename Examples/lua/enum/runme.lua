require('example')

-- Print out the value of some enums
print "*** color ***"
print(string.format("    RED    = %d", example.RED))
print(string.format("    BLUE   = %d", example.BLUE))
print(string.format("    GREEN  = %d", example.GREEN))

print "\n*** Foo::speed ***"
print(string.format("    Foo::IMPULSE   = %d", example.Foo.IMPULSE))
print(string.format("    Foo::WARP      = %d", example.Foo.WARP))
print(string.format("    Foo::LUDICROUS = %d", example.Foo.LUDICROUS))

print "\nTesting use of enums with functions"
example.enum_test(example.RED, example.Foo.IMPULSE)
example.enum_test(example.BLUE, example.Foo.WARP)
example.enum_test(example.GREEN, example.Foo.LUDICROUS)
example.enum_test(1234, 5678)

print "\nTesting use of enum with class method"
local f = example.Foo()
f:enum_test(example.Foo.IMPULSE)
f:enum_test(example.Foo.WARP)
f:enum_test(example.Foo.LUDICROUS)
