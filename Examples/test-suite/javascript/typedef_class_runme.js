var typedef_class = require("typedef_class");

var a = new typedef_class.RealA();
a.a = 3;

var b = new typedef_class.B();
/* await */(b.testA(a));
