var dynamic_cast = require("dynamic_cast");

var f = new dynamic_cast.Foo();
var b = new dynamic_cast.Bar();

var x = /* await */(f.blah());
var y = /* await */(b.blah());

var a = /* await */(dynamic_cast.do_test(y));
if (a != "Bar::test") {
  throw new Error("Failed.");
}
