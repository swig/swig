# file: runme.py
# Test various properties of classes defined in separate modules
import sys

print("Testing the %import directive with templates")

import base
import foo
import bar
import spam

def write_flush(s):
    # Python 2/3 compatible write and flush
    sys.stdout.write(s)
    sys.stdout.flush()

# Create some objects

print("Creating some objects")

a = base.intBase()
b = foo.intFoo()
c = bar.intBar()
d = spam.intSpam()

# Try calling some methods
print("Testing some methods")

write_flush("  Should see 'Base::A' ---> ")
a.A()
write_flush("  Should see 'Base::B' ---> ")
a.B()

write_flush("  Should see 'Foo::A' ---> ")
b.A()
write_flush("  Should see 'Foo::B' ---> ")
b.B()

write_flush("  Should see 'Bar::A' ---> ")
c.A()
write_flush("  Should see 'Bar::B' ---> ")
c.B()

write_flush("  Should see 'Spam::A' ---> ")
d.A()
write_flush("  Should see 'Spam::B' ---> ")
d.B()

# Try some casts

print("\nTesting some casts\n")

x = a.toBase()
write_flush("  Should see 'Base::A' ---> ")
x.A()
write_flush("  Should see 'Base::B' ---> ")
x.B()

x = b.toBase()
write_flush("  Should see 'Foo::A' ---> ")
x.A()

write_flush("  Should see 'Base::B' ---> ")
x.B()

x = c.toBase()
write_flush("  Should see 'Bar::A' ---> ")
x.A()

write_flush("  Should see 'Base::B' ---> ")
x.B()

x = d.toBase()
write_flush("  Should see 'Spam::A' ---> ")
x.A()

write_flush("  Should see 'Base::B' ---> ")
x.B()

x = d.toBar()
write_flush("  Should see 'Bar::B' ---> ")
x.B()

print("\nTesting some dynamic casts\n")
x = d.toBase()

y = foo.intFoo.fromBase(x)
print("  Spam -> Base -> Foo : {} swig".format("bad" if y else "good"))

y = bar.intBar.fromBase(x)
print("  Spam -> Base -> Bar : {} swig".format("good" if y else "bad"))

y = spam.intSpam.fromBase(x)
print("  Spam -> Base -> Spam : {} swig".format("good" if y else "bad"))

y = spam.intSpam.fromBase(b)
print("  Foo -> Spam : {} swig".format("bad" if y else "good"))
