var smart_pointer_rename = require("smart_pointer_rename");

f = new smart_pointer_rename.Foo();
b = new smart_pointer_rename.Bar(f);

if (b.test() != 3) {
    throw new Error;
}

if (b.ftest1(1) != 1) {
    throw new Error;
}

if (b.ftest2(2, 3) != 2) {
    throw new Error;
}
