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

if (b.ZZ != f.ZZ) {
    throw new Error(`Failed ${b.x} ${f.x}`);
}

if (b.z != f.z) {
    throw new Error;
}
