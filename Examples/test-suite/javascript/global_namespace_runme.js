var global_namespace = require("global_namespace");


k1 = new global_namespace.Klass1();
k2 = new global_namespace.Klass2();
k3 = new global_namespace.Klass3();
k4 = new global_namespace.Klass4();
k5 = new global_namespace.Klass5();
k6 = new global_namespace.Klass6();
k7 = new global_namespace.Klass7();

global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7);
global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7);

k1 = global_namespace.getKlass1A();
k2 = global_namespace.getKlass2A();
k3 = global_namespace.getKlass3A();
k4 = global_namespace.getKlass4A();
k5 = global_namespace.getKlass5A();
k6 = global_namespace.getKlass6A();
k7 = global_namespace.getKlass7A();

global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7);
global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7);

k1 = global_namespace.getKlass1B();
k2 = global_namespace.getKlass2B();
k3 = global_namespace.getKlass3B();
k4 = global_namespace.getKlass4B();
k5 = global_namespace.getKlass5B();
k6 = global_namespace.getKlass6B();
k7 = global_namespace.getKlass7B();

global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7);
global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7);

global_namespace.XYZMethods.methodA(new global_namespace.XYZ1(), new global_namespace.XYZ2(), new global_namespace.XYZ3(), new global_namespace.XYZ4(), new global_namespace.XYZ5(), new global_namespace.XYZ6(), new global_namespace.XYZ7());
global_namespace.XYZMethods.methodB(new global_namespace.XYZ1(), new global_namespace.XYZ2(), new global_namespace.XYZ3(), new global_namespace.XYZ4(), new global_namespace.XYZ5(), new global_namespace.XYZ6(), new global_namespace.XYZ7());

global_namespace.TheEnumMethods.methodA(global_namespace.theenum1, global_namespace.theenum2, global_namespace.theenum3);
global_namespace.TheEnumMethods.methodA(global_namespace.theenum1, global_namespace.theenum2, global_namespace.theenum3);
