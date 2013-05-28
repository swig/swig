# Test import of same modules from different packages
print "Testing %module(package=...) + %import + same modules in different packages"
import pkg2.foo
print "  Finished importing pkg2.foo"

var2 = pkg2.foo.Pkg2_Foo()
print "  Successfully created object pkg2.foo.Pkg2_Foo"
