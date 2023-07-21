var virtual_derivation = require("virtual_derivation");
//
// very innocent example
//
var b = new virtual_derivation.B(3)
if (/* await */(b.get_a()) != /* await */(b.get_b()))
    throw new Error("something is really wrong")

