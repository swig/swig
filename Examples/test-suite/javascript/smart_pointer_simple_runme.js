var smart_pointer_simple = require("smart_pointer_simple");

var f = new smart_pointer_simple.Foo();
var b = new smart_pointer_simple.Bar(f);

b.x = 3;
if (/* await */(b.getx()) != 3) {
    throw new Error;
}

var fp = /* await */(b.__deref__());
fp.x = 4;
if (/* await */(fp.getx()) != 4) {
    throw new Error;
}
