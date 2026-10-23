local v=require("template_partial_specialization")

-- One parameter tests
v.A():a()
v.B():b()
v.C():c()
v.D():d()
v.E():e()

v.F():f()
v.G():g()
v.H():h()

v.J():j()
v.K():k()
v.M():m()
v.N():n()

v.BB():b()
v.BBB():b()
v.BBBB():b()
v.BBBBB():b()

v.B1():b()
v.B2():b()
v.B3():b()
v.B4():b()

-- Two parameter tests
v.A_():a()
v.B_():b()
v.C_():c()
v.D_():d()
v.E_():e()
v.F_():f()
v.G_():g()

v.C1_():c()
v.C2_():c()
v.C3_():c()
v.C4_():c()
v.B1_():b()
v.E1_():e()
v.E2_():e()
