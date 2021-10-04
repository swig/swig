# file: runme.py

import example

print("example.Foo.bar.__doc__ = %s (Should be 'No comment')" % repr(example.Foo.bar.__doc__))
