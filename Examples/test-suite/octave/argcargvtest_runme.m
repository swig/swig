argcargvtest

largs={'hi','hola','hello'};
if (mainc(largs) != 3)
  error("bad main typemap");
endif

targs={'hi','hola'};
if (mainv(targs,1) != 'hola')
  error("bad main typemap");
endif

targs={'hi', 'hola'};
if (mainv(targs,0) != 'hi')
  error("bad main typemap");
endif
if (mainv(targs,1) != 'hola')
  error("bad main typemap");
endif
if (mainv(targs,2) != '<<NULL>>')
  error("bad main typemap");
endif

try
  error_flag = 0;
  mainv('hello',1);
  error_flag = 1;
catch
end_try_catch
if (error_flag)
  error("bad main typemap")
endif


initializeApp(largs);

# Check that an empty array works.
empty_args={};
if (mainc(empty_args) != 0)
  error("bad main typemap");
endif
if (mainv(empty_args,0) != '<<NULL>>')
  error("bad main typemap");
endif

# Check that empty strings are handled.
empty_string={"hello", blanks(0), "world"};
if (mainc(empty_string) != 3)
  error("bad main typemap");
endif
if (mainv(empty_string, 0) != "hello")
  error("bad main typemap");
endif
if (mainv(empty_string, 1) != "")
  error("bad main typemap");
endif
if (mainv(empty_string, 2) != "world")
  error("bad main typemap");
endif
if (mainv(empty_string, 3) != "<<NULL>>")
  error("bad main typemap");
endif
