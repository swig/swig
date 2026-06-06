var virtual_derivation = require("virtual_derivation");
//
// very innocent example
//
b = new virtual_derivation.B(3)
if (b.get_a() != b.get_b())
    throw new Error("something is really wrong")

