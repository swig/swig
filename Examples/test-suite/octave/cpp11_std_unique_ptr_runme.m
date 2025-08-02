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

# Test raw pointer handling involving virtual inheritance
kini = KlassInheritance("KlassInheritanceInput");
checkCount(1);
s = useKlassRawPtr(kini);
if (!strcmp(s, "KlassInheritanceInput"))
  error("Incorrect string: %s", s);
endif
clear kini;
checkCount(0);


# #### INPUT BY VALUE ####
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

null = []; # NULL pointer
null_ptr = make_null();
takeKlassUniquePtr([]);
takeKlassUniquePtr(null);
takeKlassUniquePtr(null_ptr);
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


# #### INPUT BY RVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput");
checkCount(1);
s = moveKlassUniquePtr(kin);
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
s = moveKlassUniquePtr(kin);
checkCount(0);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kin))
  error("is_nullptr failed");
endif
exception_thrown = false;
try
  moveKlassUniquePtr(kin);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
    error("double usage of moveKlassUniquePtr should have been an error");
endif
clear kin; # Should not fail, even though already deleted
checkCount(0);

kin = Klass("KlassInput");
exception_thrown = false;
notowned = get_not_owned_ptr(kin);
try
  moveKlassUniquePtr(notowned);
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
s = moveKlassUniquePtr(kini);
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
moveKlassUniquePtr([]);
moveKlassUniquePtr(null);
moveKlassUniquePtr(null_ptr);
checkCount(0);

# overloaded parameters
if (moveOverloadTest() != 0)
  error("moveOverloadTest failed");
endif
if (moveOverloadTest(null) != 1)
  error("moveOverloadTest failed");
endif
if (moveOverloadTest(Klass("over")) != 1)
  error("moveOverloadTest failed");
endif
checkCount(0);


# #### INPUT BY NON-CONST LVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput");
checkCount(1);
s = moveRefKlassUniquePtr(kin);
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
s = moveRefKlassUniquePtr(kin);
checkCount(0);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
if (!is_nullptr(kin))
  error("is_nullptr failed");
endif
exception_thrown = false;
try
  moveRefKlassUniquePtr(kin);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
    error("double usage of moveRefKlassUniquePtr should have been an error");
endif
clear kin; # Should not fail, even though already deleted
checkCount(0);

kin = Klass("KlassInput");
exception_thrown = false;
notowned = get_not_owned_ptr(kin);
try
  moveRefKlassUniquePtr(notowned);
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
s = moveRefKlassUniquePtr(kini);
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
moveRefKlassUniquePtr([]);
moveRefKlassUniquePtr(null);
moveRefKlassUniquePtr(null_ptr);
checkCount(0);

# overloaded parameters
if (moveRefOverloadTest() != 0)
  error("moveRefOverloadTest failed");
endif
if (moveRefOverloadTest(null) != 1)
  error("moveRefOverloadTest failed");
endif
if (moveRefOverloadTest(Klass("over")) != 1)
  error("moveRefOverloadTest failed");
endif
checkCount(0);


# #### INPUT BY CONST LVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput");
checkCount(1);
s = useRefKlassUniquePtr(kin);
checkCount(1);
if (!strcmp(s, "KlassInput"))
  error("Incorrect string: %s", s);
endif
clear kin;
checkCount(0);

kini = KlassInheritance("KlassInheritanceInput");
checkCount(1);
s = useRefKlassUniquePtr(kini);
checkCount(1);
if (!strcmp(s, "KlassInheritanceInput"))
  error("Incorrect string: %s", s);
endif
clear kini;
checkCount(0);

null = []; # NULL pointer
null_ptr = make_null();
useRefKlassUniquePtr([]);
useRefKlassUniquePtr(null);
useRefKlassUniquePtr(null_ptr);
checkCount(0);

# overloaded parameters
if (useRefOverloadTest() != 0)
  error("useRefOverloadTest failed");
endif
if (useRefOverloadTest(null) != 1)
  error("useRefOverloadTest failed");
endif
kin = Klass("over");
if (useRefOverloadTest(kin) != 1)
  error("useRefOverloadTest failed");
endif
checkCount(1);
clear kin
checkCount(0);


# unique_ptr as output
k1 = makeKlassUniquePtr("first");
if (!strcmp(k1.getLabel(), "first"))
  error("wrong object label");
endif

k2 = makeKlassUniquePtr("second");
checkCount(2);

clear k1;
checkCount(1);

if (!strcmp(k2.getLabel(), "second"))
  error("wrong object label");
endif

clear k2;
checkCount(0);

null_smart_prt = makeNullUniquePtr();
assert(ismatrix(null_smart_prt))
assert(size(null_smart_prt) == size([]))
assert(isequal([], null_smart_prt))

# unique_ptr as output (rvalue ref)
k1 = makeRVRKlassUniquePtr("first");
if (!strcmp(k1.getLabel(), "first"))
  error("wrong object label");
endif
k1 = makeRVRKlassUniquePtr([]);
assert(isequal([], k1))

# unique_ptr as output (lvalue ref)
k1 = makeRefKlassUniquePtr("lvalueref");
if (!strcmp(k1.getLabel(), "lvalueref"))
  error("wrong object label");
endif
k1 = makeRefKlassUniquePtr([]);
assert(isequal([], k1))
