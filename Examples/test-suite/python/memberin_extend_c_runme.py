import memberin_extend_c

t = memberin_extend_c.Person()
t.name = "some name"
if t.name != "some name":
  raise RuntimeError("some name wrong")
