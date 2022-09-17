# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

li_std_auto_ptr

function checkCount(expected_count)
  actual_count = Klass_getTotal_count();
  if (actual_count != expected_count)
    error("Counts incorrect, expected:%d actual:%d", expected_count, actual_count);
  endif
end

# Test raw pointer handling involving virtual inheritance
kini = KlassInheritance("KlassInheritanceInput");
checkCount(1);
s = useKlassRawPtr(kini);
if (!strcmp(s, "KlassInheritanceInput"))
  error("Incorrect string: %s", s);
endif
clear kini;
checkCount(0);


# auto_ptr as input
kin = Klass("KlassInput");
checkCount(1);
s = takeKlassAutoPtr(kin);
checkCount(0);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kin))
  error("is_nullptr failed");
endif
clear kin; # Should not fail, even though already deleted
checkCount(0);

kin = Klass("KlassInput");
checkCount(1);
s = takeKlassAutoPtr(kin);
checkCount(0);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kin))
  error("is_nullptr failed");
endif
exception_thrown = false;
try
  takeKlassAutoPtr(kin);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
    error("double usage of takeKlassAutoPtr should have been an error");
endif
clear kin; # Should not fail, even though already deleted
checkCount(0);

kin = Klass("KlassInput");
exception_thrown = false;
notowned = get_not_owned_ptr(kin);
try
  takeKlassAutoPtr(notowned);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
  error("Should have thrown 'Cannot release ownership as memory is not owned' error");
endif
checkCount(1);
clear kin;
checkCount(0);

kini = KlassInheritance("KlassInheritanceInput");
checkCount(1);
s = takeKlassAutoPtr(kini);
checkCount(0);
if (!strcmp(s, "KlassInheritanceInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kini))
  error("is_nullptr failed");
endif
clear kini; # Should not fail, even though already deleted
checkCount(0);

null = []; # NULL pointer
null_ptr = make_null();
takeKlassAutoPtr([]);
takeKlassAutoPtr(null);
takeKlassAutoPtr(null_ptr);
checkCount(0);

# overloaded parameters
if (overloadTest() != 0)
  error("overloadTest failed");
endif
if (overloadTest(null) != 1)
  error("overloadTest failed");
endif
if (overloadTest(Klass("over")) != 1)
  error("overloadTest failed");
endif
checkCount(0);


# auto_ptr as output
k1 = makeKlassAutoPtr("first");
if (!strcmp(k1.getLabel(), "first"))
  error("wrong object label");
endif

k2 = makeKlassAutoPtr("second");
checkCount(2);

clear k1;
checkCount(1);

if (!strcmp(k2.getLabel(), "second"))
  error("wrong object label");
endif

clear k2;
checkCount(0);

null_smart_prt = makeNullAutoPtr();
assert(ismatrix(null_smart_prt))
assert(size(null_smart_prt) == size([]))
assert(isequal([], null_smart_prt))
