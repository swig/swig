var typedef_classforward_same_name = require("typedef_classforward_same_name");

foo = new typedef_classforward_same_name.Foo();
foo.x = 5;
if (typedef_classforward_same_name.extractFoo(foo) != 5) {
    throw new Error("unexpected value");
}

boo = new typedef_classforward_same_name.Boo();
boo.x = 5;
if (typedef_classforward_same_name.extractBoo(boo) != 5) {
    throw new Error("unexpected value");
}
