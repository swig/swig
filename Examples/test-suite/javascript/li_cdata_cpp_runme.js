
var li_cdata_cpp = require("li_cdata_cpp");

/* FIXME:
 * Use null in middle of string
 * Apple JSC JSStringCreateWithUTF8CString()
 * usses null terminated string without length */
s = "ABC abc";
m = li_cdata_cpp.malloc(256);
li_cdata_cpp.memmove(m, s);
ss = li_cdata_cpp.cdata(m, 7);
if (ss !== "ABC abc") {
    throw new Error("failed");
}
