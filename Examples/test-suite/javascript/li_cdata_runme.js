
var li_cdata = require("li_cdata");

// Set "ABC abc"
s = new Uint8Array([65, 66, 67, 32, 97, 98, 99]);
m = li_cdata.malloc(256);
li_cdata.memmove(m, s);
ss = li_cdata.cdata(m, 7);
// Translate Uint8Array to string
a = ""; ss.forEach((i) => a += String.fromCharCode(i));
if (a !== "ABC abc") {
  throw new Error("failed");
}
