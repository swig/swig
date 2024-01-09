var abstract_typedef = require("abstract_typedef");

var e = new abstract_typedef.Engine();
var a = new abstract_typedef.A()

if (/* await */ (a.write(e)) != true) {
  throw "Error";
}
