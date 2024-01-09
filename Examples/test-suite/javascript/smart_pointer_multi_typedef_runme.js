var smart_pointer_multi_typedef = require("smart_pointer_multi_typedef");

var f = new smart_pointer_multi_typedef.Foo();
var b = new smart_pointer_multi_typedef.Bar(f);
var s = new smart_pointer_multi_typedef.Spam(b);
var g = new smart_pointer_multi_typedef.Grok(b);

s.x = 3;
if (/* await */(s.getx()) != 3) {
    throw new Error;
}

g.x = 4;
if (/* await */(g.getx()) != 4) {
    throw new Error;
}
