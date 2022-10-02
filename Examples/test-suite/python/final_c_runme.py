import final_c

final_c.init()
f = final_c.cvar.final
if (f.yval != 123):
  raise RuntimeError("f.yval fail")
