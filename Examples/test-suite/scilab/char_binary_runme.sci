exec("swigtest.start", -1);

t = new_Test();
str = "hile";
if Test_strlen(t, str) <> 4 then
  swigtesterror("bad multi-arg typemap");
end
if Test_ustrlen(t, str) <> 4 then
  swigtesterror("bad multi-arg typemap");
end
// String can not contain null character same as C

// creating a raw char*
pc = new_pchar(5);
pchar_setitem(pc, 0, 'h');
pchar_setitem(pc, 1, 'o');
pchar_setitem(pc, 2, 'l');
pchar_setitem(pc, 3, 'a');
pchar_setitem(pc, 4, ascii(0));

// FIXME: pc is not 'char const *'
if 0 then
  if Test_strlen(t, pc) <> 4 then
    swigtesterror("bad multi-arg typemap");
  end
  if Test_ustrlen(t, pc) <> 4 then
    swigtesterror("bad multi-arg typemap");
  end
end

// FIXME: pc is not string
if 0 then
  var_pchar_set(pc);a
else
  var_pchar_set("hola");
end
if var_pchar_get() <> "hola" then
  swigtesterror("bad pointer case");
end

// FIXME: pc is not string
if 0 then
  var_namet_set(pc);
else
  var_namet_set("hola");
end
if var_namet_get() <> "hola" then
  swigtesterror("bad pointer case");
end

delete_pchar(pc);

exec("swigtest.quit", -1);
