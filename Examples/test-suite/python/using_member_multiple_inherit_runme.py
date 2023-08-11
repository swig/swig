from using_member_multiple_inherit import *

# Single inheritance three deep, overload using and methods
u3 = Using3()
u3.usingmethod(11)
u3.usingmethod(11, 22)
u3.usingmethod(11, 22, 33)

# Multiple inheritance, multiple using declarations
ma = MultMiddleA()
ma.multmethod(123)
ma.multmethod("hi")
ma.multmethod(123, 234)

mb = MultBottomB()
mb.multmethod(123)
mb.multmethod("hi")
mb.multmethod(123, 234)
mb.multmethod(123, 345, 567)
