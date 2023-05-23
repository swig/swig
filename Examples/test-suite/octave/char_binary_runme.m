char_binary

t = char_binary.Test();
str = "hile";
if (t.strlen(str) != 4)
  disp(t.strlen(str));
  error("bad multi-arg typemap");
endif
if (t.ustrlen(str) != 4)
  disp(t.ustrlen(str));
  error("bad multi-arg typemap");
endif

if (t.strlen("hil\000") != 4)
  error("bad multi-arg typemap");
endif
if (t.ustrlen("hil\000") != 4)
  error("bad multi-arg typemap");
endif

% creating a raw char*
pc = new_pchar(5);
pchar_setitem(pc, 0, 'h');
pchar_setitem(pc, 1, 'o');
pchar_setitem(pc, 2, 'l');
pchar_setitem(pc, 3, 'a');
pchar_setitem(pc, 4, 0);
delete_pchar(pc);
