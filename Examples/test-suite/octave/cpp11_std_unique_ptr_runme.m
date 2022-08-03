# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

cpp11_std_unique_ptr

function checkCount(expected_count)
  actual_count = Klass_getTotal_count();
  if (actual_count != expected_count)
    error("Counts incorrect, expected:%d actual:%d", expected_count, actual_count);
  endif
end


# unique_ptr as input
kin = Klass("KlassInput");
checkCount(1);
s = takeKlassUniquePtr(kin);
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
s = takeKlassUniquePtr(kin);
checkCount(0);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kin))
  error("is_nullptr failed");
endif
exception_thrown = false;
try
  takeKlassUniquePtr(kin);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
    error("double usage of takeKlassUniquePtr should have been an error");
endif
clear kin; # Should not fail, even though already deleted
checkCount(0);

kin = Klass("KlassInput");
exception_thrown = false;
notowned = get_not_owned_ptr(kin);
try
  takeKlassUniquePtr(notowned);
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
s = takeKlassUniquePtr(kini);
checkCount(0);
if (!strcmp(s, "KlassInheritanceInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kini))
  error("is_nullptr failed");
endif
clear kini; # Should not fail, even though already deleted
checkCount(0);


# unique_ptr as output
k1 = makeKlassUniquePtr("first");
if (!strcmp(k1.getLabel(), "first"))
  error("wrong object label");
endif

k2 = makeKlassUniquePtr("second");
if (Klass_getTotal_count() != 2)
  error("number of objects should be 2");
endif

clear k1;
if (Klass.getTotal_count() != 1)
  error("number of objects should be 1");
endif

if (!strcmp(k2.getLabel(), "second"))
  error("wrong object label");
endif

clear k2;
if (Klass.getTotal_count() != 0)
  error("no objects should be left");
endif
