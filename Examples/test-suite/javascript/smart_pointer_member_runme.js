var smart_pointer_member = require("smart_pointer_member");


f = new smart_pointer_member.Foo();
f.y = 1;

if (f.y != 1) {
    throw new Error;
}

b = new smart_pointer_member.Bar(f);
b.y = 2;

if (f.y != 2) {
    throw new Error(`Failed ${f.y} ${f.x}`);
}

if (typeof print === undefined) {
  // These do not work in JSC
  if (f.constructor.ZZ !== b.constructor.ZZ && f.constructor.ZZ !== undefined) {
    throw new Error(`Failed ${f.constructor.ZZ} ${b.constructor.ZZ}`);
  }

  if (f.constructor.z !== b.constructor.z && f.constructor.z !== undefined) {
    throw new Error;
  }
}

if (smart_pointer_member.Foo.ZZ !== smart_pointer_member.Bar.ZZ && smart_pointer_member.Foo.ZZ !== undefined) {
  throw new Error(`Failed ${smart_pointer_member.Foo.ZZ} ${smart_pointer_member.Bar.ZZ}`);
}

if (smart_pointer_member.Foo.z !== smart_pointer_member.Bar.z && smart_pointer_member.Foo.z !== undefined) {
    throw new Error;
}
