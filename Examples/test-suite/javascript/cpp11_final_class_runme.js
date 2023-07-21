var cpp11_final_class = require("cpp11_final_class");

var fc1 = new cpp11_final_class.FinalClass1();
/* await */(fc1.method1());

var fc2 = new cpp11_final_class.FinalClass2();
/* await */(fc2.method2());

var fc3 = new cpp11_final_class.FinalClass3();
/* await */(fc3.method3());

var fc4 = new cpp11_final_class.FinalClass4();
/* await */(fc4.method4());
var fc4final = cpp11_final_class.final;
/* await */(cpp11_final_class.final.method4());

var fc5 = new cpp11_final_class.FinalClass5();
/* await */(fc5.method5());
/* await */(fc5.final_member_var.finalmethod());
var fc5final = /* await */(fc5.get_final_member());
/* await */(fc5final.finalmethod());
fc5final = /* await */(fc5.get_final_member2());
/* await */(fc5final.finalmethod());

var fc6 = new cpp11_final_class.FinalClass6();
/* await */(fc6.method6());
/* await */(fc6.final());

var o = new cpp11_final_class.override();
/* await */(o.omethod());

var y = new cpp11_final_class.Y();
var fv4 = new cpp11_final_class.FinalVar4();
var yy = fv4.final;

var fv5 = new cpp11_final_class.FinalVar5();
yy = fv5.final;

var fv6 = new cpp11_final_class.FinalVar6();
yy = fv6.final;

var fv7 = new cpp11_final_class.FinalVar7();
yy = fv7.final;

var fv8 = new cpp11_final_class.FinalVar8();
yy = fv8.final;

var fv9 = new cpp11_final_class.FinalVar9();
yy = fv9.final;

var fv10 = new cpp11_final_class.FinalVar10();
/* await */(fv10.b10(y));

// Removed due to Visual C++ compiler limitations
/*fv11 = FinalVar11()
fv11.a11(y)
fe1 = FinalEnum1()
fe1.enum_in(FinalEnum1.final)

fe2 = FinalEnum2()
fe2f = fe2.final*/

var s3f = new cpp11_final_class.Space3_final();
/* await */(s3f.fmethod());
