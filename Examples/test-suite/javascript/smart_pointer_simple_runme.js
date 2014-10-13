var smart_pointer_simple = require("smart_pointer_simple");

var f = new smart_pointer_simple.Foo()
var b = new smart_pointer_simple.Bar(f)

b.x = 3
if (b.getx() != 3)
    throw new Error("Expected 3");

fp = b.__deref__()
fp.x = 4
if (fp.getx() != 4)
    throw new Error("Expected 4");
