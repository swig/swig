var inctest = require("inctest");

try {
    a = new inctest.A();
} catch (e) {
    throw new Error("didn't find A, therefore, I didn't include 'testdir/subdir1/hello.i'");
}

try {
    b = new inctest.B();
} catch (e) {
    throw new Error("didn't find B, therefore, I didn't include 'testdir/subdir2/hello.i'");
}

// Check the var in subdirectory worked = require("in subdirectory worked")
if (inctest.importtest1(5) != 15) {
    throw new Error("var test 1 failed");
}

if (inctest.importtest2("black") != "white") {
    throw new Error("var test 2 failed");
}
