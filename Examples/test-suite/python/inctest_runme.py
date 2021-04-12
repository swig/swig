import inctest

try:
    a = inctest.A()
except:
    raise RuntimeError("didn't find A, therefore, I didn't include 'testdir/subdir1/hello.i'")
pass


try:
    b = inctest.B()
except:
    raise RuntimeError("didn't find B, therefore, I didn't include 'testdir/subdir2/hello.i'")
pass

# Check the import in subdirectory worked
if inctest.importtest1(5) != 15:
    raise RuntimeError("import test 1 failed")

if inctest.importtest2("black") != "white":
    raise RuntimeError("import test 2 failed")
