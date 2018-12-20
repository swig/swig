import python_pythoncode

# No need to actually do anything, this is a regression test for a bug which
# caused an invalid python_pythoncode.py to be generated, so if we can import
# it the bug is still fixed.

# A later test enhancement checking __new__ requires some code...
f = python_pythoncode.get_foo()
f = python_pythoncode.Foo()
