var example = require("./example");

console.log("ICONST  = " + example.ICONST  + " (should be 42)\n");
console.log("FCONST  = " + example.FCONST  + " (should be 2.1828)\n");
console.log("CCONST  = " + example.CCONST  + " (should be 'x')\n");  
console.log("CCONST2 = " + example.CCONST2 + " (this should be on a new line)\n"); 
console.log("SCONST  = " + example.SCONST  + " (should be 'Hello World')\n");
console.log("SCONST2 = " + example.SCONST2 + " (should be '\"Hello World\"')\n");
console.log("EXPR    = " + example.EXPR    + " (should be 48.5484)\n");
console.log("iconst  = " + example.iconst  + " (should be 37)\n"); 
console.log("fconst  = " + example.fconst  + " (should be 3.14)\n"); 

console.log("EXTERN = " + example.EXTERN   + " (should be undefined)\n");
console.log("FOO    = " + example.FOO      + " (should be undefined)\n");
