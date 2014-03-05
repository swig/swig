import pkg1.pkg2.foo
print "  Finished importing pkg1.pkg2.foo"

var2 = pkg1.pkg2.foo.Pkg2_Foo();
if str(type(var2)).find("'pkg1.pkg2.foo.Pkg2_Foo'") == -1:
  raise RuntimeError("failed type checking: " + str(type(var2)))
print "  Successfully created object pkg1.pkg2.foo.Pkg2_Foo"
