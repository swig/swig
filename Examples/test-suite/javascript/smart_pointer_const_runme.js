var smart_pointer_const = require('smart_pointer_const');

var f = new smart_pointer_const.Foo;
var b = new smart_pointer_const.Bar(f);

b.x = 3;
if (b.getx() != 3) throw new Error('Failed');

var fp = b.__deref__();
fp.x = 4;
if (b.getx() != 4) throw new Error('Failed');
