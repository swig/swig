from using_member_multiple_inherit import *

# Single inheritance three deep, only using declarations
s3 = Susing3()
s3.usingmethod(11)

# Single inheritance three deep, overload using and methods
u3 = Using3()
u3.usingmethod(11)
u3.usingmethod(11, 22)
u3.usingmethod(11, 22, 33)

m3 = Musing3()
m3.usingmethod(11)
m3.usingmethod(11, 22)
m3.usingmethod(11, 22, 33)

d3 = Dusing3()
d3.usingmethod(11)
d3.usingmethod(11, 22)

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

# Multiple inheritance, with no override on parent class. 
vu = Vusing2()
vu.usingmethod(3)
vu.usingmethod("hi")
