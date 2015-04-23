# file: runme.py
# Test various properties of classes defined in separate modules

print "Testing the %import directive with templates"
import base
import foo
import bar
import spam

# Create some objects

print "Creating some objects"

a = base.intBase()
b = foo.intFoo()
c = bar.intBar()
d = spam.intSpam()

# Try calling some methods
print "Testing some methods"
print "",
print "Should see 'Base::A' ---> ",
a.A()
print "Should see 'Base::B' ---> ",
a.B()

print "Should see 'Foo::A' ---> ",
b.A()
print "Should see 'Foo::B' ---> ",
b.B()

print "Should see 'Bar::A' ---> ",
c.A()
print "Should see 'Bar::B' ---> ",
c.B()

print "Should see 'Spam::A' ---> ",
d.A()
print "Should see 'Spam::B' ---> ",
d.B()

# Try some casts

print "\nTesting some casts\n"
print "",

x = a.toBase()
print "Should see 'Base::A' ---> ",
x.A()
print "Should see 'Base::B' ---> ",
x.B()

x = b.toBase()
print "Should see 'Foo::A' ---> ",
x.A()

print "Should see 'Base::B' ---> ",
x.B()

x = c.toBase()
print "Should see 'Bar::A' ---> ",
x.A()

print "Should see 'Base::B' ---> ",
x.B()

x = d.toBase()
print "Should see 'Spam::A' ---> ",
x.A()

print "Should see 'Base::B' ---> ",
x.B()

x = d.toBar()
print "Should see 'Bar::B' ---> ",
x.B()

print "\nTesting some dynamic casts\n"
x = d.toBase()

print " Spam -> Base -> Foo : ",
y = foo.intFoo_fromBase(x)
if y:
    print "bad swig"
else:
    print "good swig"

print " Spam -> Base -> Bar : ",
y = bar.intBar_fromBase(x)
if y:
    print "good swig"
else:
    print "bad swig"

print " Spam -> Base -> Spam : ",
y = spam.intSpam_fromBase(x)
if y:
    print "good swig"
else:
    print "bad swig"

print " Foo -> Spam : ",
y = spam.intSpam_fromBase(b)
if y:
    print "bad swig"
else:
    print "good swig"
