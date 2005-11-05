import profiletest       

a = profiletest.A()
b = profiletest.B()
i = 50000
while i:
  a = b.fn(a) #1
  a = b.fn(a) #2
  a = b.fn(a) #3
  a = b.fn(a) #4
  a = b.fn(a) #5
  a = b.fn(a) #6
  a = b.fn(a) #7
  a = b.fn(a) #8
  a = b.fn(a) #9
  a = b.fn(a) #10
  a = b.fn(a) #1
  a = b.fn(a) #2
  a = b.fn(a) #3
  a = b.fn(a) #4
  a = b.fn(a) #5
  a = b.fn(a) #6
  a = b.fn(a) #7
  a = b.fn(a) #8
  a = b.fn(a) #9
  a = b.fn(a) #20
  i -= 1
