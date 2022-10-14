from cpp11_final_class import *

fc1 = FinalClass1()
fc1.method1()

fc2 = FinalClass2()
fc2.method2()

fc3 = FinalClass3()
fc3.method3()

fc4 = FinalClass4()
fc4.method4()
fc4final = cvar.final
cvar.final.method4()

fc5 = FinalClass5()
fc5.method5()
fc5.final_member_var.finalmethod()
fc5final = fc5.get_final_member()
fc5final.finalmethod()
fc5final = fc5.get_final_member2()
fc5final.finalmethod()

fc6 = FinalClass6()
fc6.method6()
fc6.final()

o = override()
o.omethod();

y = Y()
fv4 = FinalVar4()
yy = fv4.final

fv5 = FinalVar5()
yy = fv5.final

fv6 = FinalVar6()
yy = fv6.final

fv7 = FinalVar7()
yy = fv7.final

fv8 = FinalVar8()
yy = fv8.final

fv9 = FinalVar9()
yy = fv9.final

fv10 = FinalVar10()
fv10.b10(y)

# Removed due to Visual C++ compiler limitations
# fv11 = FinalVar11()
# fv11.a11(y)
#
# fe1 = FinalEnum1()
# fe1.enum_in(FinalEnum1.final)
#
# fe2 = FinalEnum2()
# fe2f = fe2.final

s3f = Space3_final()
s3f.fmethod();
