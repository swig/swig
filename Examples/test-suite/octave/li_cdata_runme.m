li_cdata

s = "ABC\000abc";
m = li_cdata.malloc(256);
li_cdata.memmove(m, s);
ss = li_cdata.cdata(m, 7);
if (ss != "ABC\000abc")
  disp(ss);
  error("failed");
endif
