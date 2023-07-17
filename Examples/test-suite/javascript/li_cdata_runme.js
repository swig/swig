
var li_cdata = require("li_cdata");

var s = "ABC abc";
var m = /* await */(li_cdata.malloc(256));
/* await */(li_cdata.memmove(m, s));
var ss = /* await */(li_cdata.cdata(m, 7));
if (ss !== "ABC abc") {
    throw new Error("failed");
}
