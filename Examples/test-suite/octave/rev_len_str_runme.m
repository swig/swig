rev_len_str

t = rev_len_str.Test();
str = "hile";
if (t.strlen(str) != 4)
  disp(t.strlen(str));
  error("bad multi-arg typemap");
endif

if (t.strlen("hil\000") != 4)
  error("bad multi-arg typemap");
endif
