require("import")
require("li_cdata_cpp")
v=li_cdata_cpp
catch_undef_globs() -- catch "undefined" global variables

s = "ABC\0abc"
m = v.malloc(256)
v.memmove(m, s)
ss = v.cdata(m, 7)
if ss ~= "ABC\0abc" then
   error("failed")
end
