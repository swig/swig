from smart_pointer_not import *

f = Foo()
b = Bar(f)
s = Spam(f)
g = Grok(f)

try:
    x = b.x
    raise RuntimeError("Error! b.x")
except AttributeError:
    pass

try:
    x = s.x
    raise RuntimeError("Error! s.x")
except AttributeError:
    pass

try:
    x = g.x
    raise RuntimeError("Error! g.x")
except AttributeError:
    pass

try:
    x = b.getx()
    raise RuntimeError("Error! b.getx()")
except AttributeError:
    pass

try:
    x = s.getx()
    raise RuntimeError("Error! s.getx()")
except AttributeError:
    pass

try:
    x = g.getx()
    raise RuntimeError("Error! g.getx()")
except AttributeError:
    pass
