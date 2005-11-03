import profiletest       

a = profiletest.A()
b = profiletest.B()
for i in range(0,1000000):
  a = b.fn(a)
