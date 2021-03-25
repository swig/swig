# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

overload_null

function check(a, b)
  if (a != b)
    error("%i does not equal %i", a, b);
  endif
end

o = Overload();
x = X();
null = []; # NULL pointer

check(1, o.byval1(x));
check(2, o.byval1(null));

check(3, o.byval2(null));
check(4, o.byval2(x));

check(5, o.byref1(x));
check(6, o.byref1(null));

check(7, o.byref2(null));
check(8, o.byref2(x));

check(9, o.byconstref1(x));
check(10, o.byconstref1(null));

check(11, o.byconstref2(null));
check(12, o.byconstref2(x));

# const pointer references
check(13, o.byval1cpr(x));
check(14, o.byval1cpr(null));

check(15, o.byval2cpr(null));
check(16, o.byval2cpr(x));

# forward class declaration
check(17, o.byval1forwardptr(x));
check(18, o.byval1forwardptr(null));

check(19, o.byval2forwardptr(null));
check(20, o.byval2forwardptr(x));

check(21, o.byval1forwardref(x));

check(22, o.byval2forwardref(x));
