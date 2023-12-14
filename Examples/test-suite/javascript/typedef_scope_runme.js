var typedef_scope = require("typedef_scope");

var b = new typedef_scope.Bar();
var x = /* await */(b.test1(42,"hello"));
if (x != 42)
    throw new Error("Failed!!");

x = /* await */(b.test2(42,"hello"));
if (x != "hello")
    throw new Error("Failed!!");


