
var li_cdata_cpp = require("li_cdata_cpp");

// Set "ABC abc"
s = new Uint8Array([65, 66, 67, 32, 97, 98, 99]);
m = li_cdata_cpp.malloc(256);
li_cdata_cpp.memmove(m, s);
ss = li_cdata_cpp.cdata(m, 7);
// Translate Uint8Array to string
a = ""; ss.forEach((i) => a += String.fromCharCode(i));
if (a !== "ABC abc") {
  throw new Error("failed");
}
