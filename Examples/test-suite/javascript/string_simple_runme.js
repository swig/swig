var string_simple = require("string_simple");

// Test unicode string
var str = "olé";

var copy = string_simple.copy_str(str);

if (str !== copy) {
  throw "Error: copy is not equal: original="+str+", copy="+copy;
}
