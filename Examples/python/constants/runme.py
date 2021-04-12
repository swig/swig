# file: runme.py

import example

print("ICONST  = %s (should be 42)" % example.ICONST)
print("FCONST  = %s (should be 2.1828)" % example.FCONST)
print("CCONST  = %s (should be 'x')" % example.CCONST)
print("CCONST2 = %s (this should be on a new line)" % example.CCONST2)
print("SCONST  = %s (should be 'Hello World')" % example.SCONST)
print("SCONST2 = %s (should be '\"Hello World\"')" % example.SCONST2)
print("EXPR    = %s (should be 48.5484)" % example.EXPR)
print("iconst  = %s (should be 37)" % example.iconst)
print("fconst  = %s (should be 3.14)" % example.fconst)

try:
    x = example.EXTERN
    print("%s (Arg! This shouldn't print anything)" % x)
except AttributeError:
    print("EXTERN isn't defined (good)")

try:
    x = example.FOO
    print("%s (Arg! This shouldn't print anything)" % x)
except AttributeError:
    print("FOO isn't defined (good)")
