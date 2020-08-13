from smart_pointer_not import *

f = Foo()
b = Bar(f)
s = Spam(f)
g = Grok(f)

try:
    x = b.x
    print "Error! b.x"
except AttributeError:
    pass

try:
    x = s.x
    print "Error! s.x"
except AttributeError:
    pass

try:
    x = g.x
    print "Error! g.x"
except AttributeError:
    pass

try:
    x = b.getx()
    print "Error! b.getx()"
except AttributeError:
    pass

try:
    x = s.getx()
    print "Error! s.getx()"
except AttributeError:
    pass

try:
    x = g.getx()
    print "Error! g.getx()"
except AttributeError:
    pass
