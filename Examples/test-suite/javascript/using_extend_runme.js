var using_extend = require("using_extend");

f = new using_extend.FooBar();
if (f.blah(3) != 3) {
    throw new Error("blah(int)");
}

if (f.blah(3.5) != 3.5) {
    throw new Error("blah(double)");
}

if (f.blah("hello") != "hello") {
    throw new Error("blah(char *)");
}

if (f.blah(3, 4) != 7) {
    throw new Error("blah(int,int)");
}

if (f.blah(3.5, 7.5) != (3.5 + 7.5)) {
    throw new Error("blah(double,double)");
}


if (f.duh(3) != 3) {
    throw new Error("duh(int)");
}
