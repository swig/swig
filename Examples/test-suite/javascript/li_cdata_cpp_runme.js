
var li_cdata_cpp = require("li_cdata_cpp");

s = "ABC abc";
m = li_cdata_cpp.malloc(256);
li_cdata_cpp.memmove(m, s);
ss = li_cdata_cpp.cdata(m, 7);
if (ss !== "ABC abc") {
    throw new Error("failed");
}
