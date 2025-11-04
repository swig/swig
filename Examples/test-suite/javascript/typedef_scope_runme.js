var typedef_scope = require("typedef_scope");

var b = new typedef_scope.Bar();
var x = b.test1(42,"hello");
if (x != 42)
    print("Failed!!");

x = b.test2(42,"hello");
if (x != "hello")
    print("Failed!!");


