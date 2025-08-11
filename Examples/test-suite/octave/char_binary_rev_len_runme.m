char_binary_rev_len

t = char_binary_rev_len.Test();
str = "hile";
if (t.strlen(str) != 4)
  disp(t.strlen(str));
  error("bad multi-arg typemap 1");
endif

if (t.strlen("hil\000") != 4)
  error("bad multi-arg typemap 2");
endif
t2 = char_binary_rev_len.Test(str);
if (t2.getisize() != 4)
 error("bad multi-arg typemap 3");
endif
if (t2.strlen("hil\000a") != 5)
 error("bad multi-arg typemap 4");
endif
