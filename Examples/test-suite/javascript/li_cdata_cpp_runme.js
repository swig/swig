
var li_cdata_cpp = require("li_cdata_cpp");

/* FIXME:
 * Use null in middle of string
 * Apple JSC JSStringCreateWithUTF8CString()
 * usses null terminated string without length */
var s = "ABC abc";
var m = /* await */(li_cdata_cpp.malloc(256));
/* await */(li_cdata_cpp.memmove(m, s));
var ss = /* await */(li_cdata_cpp.cdata(m, 7));
if (ss !== "ABC abc") {
    throw new Error("failed");
}
