var typedef_typedef = require("typedef_typedef");

var b = new typedef_typedef.B();
if (/* await */(b.getValue(123)) != 1234) {
    throw new Error("Failed");
}
