var smart_pointer_typedef = require("smart_pointer_typedef");

var f = new smart_pointer_typedef.Foo();
var b = new smart_pointer_typedef.Bar(f);

b.x = 3;
if (/* await */(b.getx()) != 3) {
    throw new Error;
}

var fp = /* await */(b.__deref__());
fp.x = 4;
if (/* await */(fp.getx()) != 4) {
    throw new Error;
}
