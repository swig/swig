var global_namespace = require("global_namespace");


var k1 = new global_namespace.Klass1();
var k2 = new global_namespace.Klass2();
var k3 = new global_namespace.Klass3();
var k4 = new global_namespace.Klass4();
var k5 = new global_namespace.Klass5();
var k6 = new global_namespace.Klass6();
var k7 = new global_namespace.Klass7();

/* await */(global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7));
/* await */(global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7));

k1 = /* await */(global_namespace.getKlass1A());
k2 = /* await */(global_namespace.getKlass2A());
k3 = /* await */(global_namespace.getKlass3A());
k4 = /* await */(global_namespace.getKlass4A());
k5 = /* await */(global_namespace.getKlass5A());
k6 = /* await */(global_namespace.getKlass6A());
k7 = /* await */(global_namespace.getKlass7A());

/* await */(global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7));
/* await */(global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7));

k1 = /* await */(global_namespace.getKlass1B());
k2 = /* await */(global_namespace.getKlass2B());
k3 = /* await */(global_namespace.getKlass3B());
k4 = /* await */(global_namespace.getKlass4B());
k5 = /* await */(global_namespace.getKlass5B());
k6 = /* await */(global_namespace.getKlass6B());
k7 = /* await */(global_namespace.getKlass7B());

/* await */(global_namespace.KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7));
/* await */(global_namespace.KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7));

/* await */(global_namespace.XYZMethods.methodA(new global_namespace.XYZ1(), new global_namespace.XYZ2(), new global_namespace.XYZ3(), new global_namespace.XYZ4(), new global_namespace.XYZ5(), new global_namespace.XYZ6(), new global_namespace.XYZ7()));
/* await */(global_namespace.XYZMethods.methodB(new global_namespace.XYZ1(), new global_namespace.XYZ2(), new global_namespace.XYZ3(), new global_namespace.XYZ4(), new global_namespace.XYZ5(), new global_namespace.XYZ6(), new global_namespace.XYZ7()));

/* await */(global_namespace.TheEnumMethods.methodA(global_namespace.theenum1, global_namespace.theenum2, global_namespace.theenum3));
/* await */(global_namespace.TheEnumMethods.methodA(global_namespace.theenum1, global_namespace.theenum2, global_namespace.theenum3));
