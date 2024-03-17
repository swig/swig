
var li_cdata = require("li_cdata");

s = "ABC abc";
m = li_cdata.malloc(256);
li_cdata.memmove(m, s);
ss = li_cdata.cdata(m, 7);
if (ss !== "ABC abc") {
    throw new Error("failed");
}
