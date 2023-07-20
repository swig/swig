var smart_pointer_multi = require("smart_pointer_multi");

var f = new smart_pointer_multi.Foo();
var b = new smart_pointer_multi.Bar(f);
var s = new smart_pointer_multi.Spam(b);
var g = new smart_pointer_multi.Grok(b);

s.x = 3;
if (/* await */(s.getx()) != 3) {
    throw new Error;
}

g.x = 4;
if (/* await */(g.getx()) != 4) {
    throw new Error;
}
