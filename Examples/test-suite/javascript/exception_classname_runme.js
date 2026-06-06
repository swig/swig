var exception_classname = require("exception_classname");

a = new exception_classname.Exception();
if (a.testfunc() != 42) {
    throw new Error("Not 42!");
}
