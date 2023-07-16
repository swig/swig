var constover = require("constover");

var p = /* await */(constover.test("test"));
if (p != "test") {
    throw "test failed!";
}

p = /* await */(constover.test_pconst("test"));
if (p != "test_pconst") {
    throw "test_pconst failed!";
}

var f = new constover.Foo();

p = /* await */(f.test("test"));
if (p != "test") {
    throw "member-test failed!";
}

p = /* await */(f.test_pconst("test"));
if (p != "test_pconst") {
    throw "member-test_pconst failed!";
}

p = /* await */(f.test_constm("test"));
if (p != "test_constmethod") {
    throw "member-test_constm failed!";
}

p = /* await */(f.test_pconstm("test"));
if (p != "test_pconstmethod") {
    throw "member-test_pconstm failed!";
}
