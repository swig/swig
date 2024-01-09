var smart_pointer_member = require("smart_pointer_member");


var f = new smart_pointer_member.Foo();
f.y = 1;

if (f.y != 1) {
    throw new Error;
}

var b = new smart_pointer_member.Bar(f);
b.y = 2;

/* @ts-ignore */
if (f.y !== 2) {
    throw new Error(`Failed ${f.y} ${f.x}`);
}

/**
TODO:
This test is broken in Javascript, it was masked by comparing undefined == undefined
Normally, static properties of a class cannot be accessed through an instance of the class
There is the somewhat hackish workaround of accessing the class constructor function
which is the class itself

In any case, what should be implemented is that Bar.ZZ should be Foo.ZZ when Bar is a smart pointer

if (b.constructor.ZZ !== f.constructor.ZZ) {
  throw new Error(`Failed ${smart_pointer_member.Foo.ZZ} ${smart_pointer_member.Bar.ZZ}`);
}

if (b.constructor.z !== f.constructor.z) {
    throw new Error;
}
*/

if (typeof print === 'undefined') {
  /* @ts-ignore */
  if (f.constructor.ZZ !== 3) {
    throw new Error(`Failed Foo.ZZ = ${smart_pointer_member.Foo.ZZ}`);
  }

  /* @ts-ignore */
  if (f.constructor.z !== 3) {
    throw new Error;
  }
}
