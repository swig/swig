
var li_cdata_cpp = require("li_cdata_cpp");

var s = "ABC abc";
var m = /* await */(li_cdata_cpp.malloc(256));
/* await */(li_cdata_cpp.memmove(m, s));
var ss = /* await */(li_cdata_cpp.cdata(m, 7));
if (ss !== "ABC abc") {
    throw new Error("failed");
}
