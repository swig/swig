char_binary_rev_len

t = char_binary_rev_len.Test();
str = "hile";
if (t.strlen(str) != 4)
  disp(t.strlen(str));
  error("bad multi-arg typemap");
endif

if (t.strlen("hil\000") != 4)
  error("bad multi-arg typemap");
endif
