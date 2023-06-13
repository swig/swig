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

if (0)
  % FIXME: Can not convert to const (SWIG_TypeError)
  if (t.strlen(pc) != 4)
    error("bad multi-arg typemap");
  endif

  % FIXME: Can not convert to const (SWIG_TypeError)
  if (t.ustrlen(pc) != 4)
    error("bad multi-arg typemap");
  endif
endif

char_binary.var_pchar = pc;
if (0)
  % FIXME: could not dispatch binary operator
  if (char_binary.var_pchar != "hola")
    error("bad pointer case");
  endif
endif

char_binary.var_namet = pc;
if (0)
  % FIXME: could not dispatch binary operator
  if (char_binary.var_namet != "hola")
    error("bad pointer case");
  endif
endif

delete_pchar(pc);
