li_cdata_cpp

s = "ABC\000abc";
m = li_cdata_cpp.malloc(256);
li_cdata_cpp.memmove(m, s);
ss = li_cdata_cpp.cdata(m, 7);
if (ss != "ABC\000abc")
  disp(ss);
  error("failed");
endif
