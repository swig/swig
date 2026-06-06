var cpp11_final_class = require("cpp11_final_class");

fc1 = new cpp11_final_class.FinalClass1();
fc1.method1();

fc2 = new cpp11_final_class.FinalClass2();
fc2.method2();

fc3 = new cpp11_final_class.FinalClass3();
fc3.method3();

fc4 = new cpp11_final_class.FinalClass4();
fc4.method4();
fc4final = cpp11_final_class.final;
cpp11_final_class.final.method4();

fc5 = new cpp11_final_class.FinalClass5();
fc5.method5();
fc5.final_member_var.finalmethod();
fc5final = fc5.get_final_member();
fc5final.finalmethod();
fc5final = fc5.get_final_member2();
fc5final.finalmethod();

fc6 = new cpp11_final_class.FinalClass6();
fc6.method6();
fc6.final();

o = new cpp11_final_class.override();
o.omethod();

y = new cpp11_final_class.Y();
fv4 = new cpp11_final_class.FinalVar4();
yy = fv4.final;

fv5 = new cpp11_final_class.FinalVar5();
yy = fv5.final;

fv6 = new cpp11_final_class.FinalVar6();
yy = fv6.final;

fv7 = new cpp11_final_class.FinalVar7();
yy = fv7.final;

fv8 = new cpp11_final_class.FinalVar8();
yy = fv8.final;

fv9 = new cpp11_final_class.FinalVar9();
yy = fv9.final;

fv10 = new cpp11_final_class.FinalVar10();
fv10.b10(y);

// Removed due to Visual C++ compiler limitations
/*fv11 = FinalVar11()
fv11.a11(y)
fe1 = FinalEnum1()
fe1.enum_in(FinalEnum1.final)

fe2 = FinalEnum2()
fe2f = fe2.final*/

s3f = new cpp11_final_class.Space3_final();
s3f.fmethod();
