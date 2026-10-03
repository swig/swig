% Ownership transfer must clear the native pointer without invalidating the proxy.
k = li_std_auto_ptr.Klass('input');
assert(li_std_auto_ptr.Klass.getTotal_count() == 1);
assert(strcmp(li_std_auto_ptr.takeKlassAutoPtr(k), 'input'));
assert(li_std_auto_ptr.Klass.getTotal_count() == 0);
assert(li_std_auto_ptr.is_nullptr(k));
failed = false;
try
  li_std_auto_ptr.takeKlassAutoPtr(k);
catch
  failed = true;
end
assert(failed);
delete(k);
assert(li_std_auto_ptr.Klass.getTotal_count() == 0);

k = li_std_auto_ptr.Klass('owned');
borrowed = li_std_auto_ptr.get_not_owned_ptr(k);
failed = false;
try
  li_std_auto_ptr.takeKlassAutoPtr(borrowed);
catch
  failed = true;
end
assert(failed);
assert(li_std_auto_ptr.Klass.getTotal_count() == 1);
delete(borrowed);
assert(strcmp(k.getLabel(), 'owned'));
delete(k);
assert(li_std_auto_ptr.Klass.getTotal_count() == 0);

k = li_std_auto_ptr.KlassInheritance('derived');
assert(strcmp(li_std_auto_ptr.takeKlassAutoPtr(k), 'derived'));
assert(li_std_auto_ptr.is_nullptr(k));
delete(k);
assert(li_std_auto_ptr.Klass.getTotal_count() == 0);
k = li_std_auto_ptr.makeKlassAutoPtr('output');
assert(strcmp(k.getLabel(), 'output'));
delete(k);
assert(li_std_auto_ptr.Klass.getTotal_count() == 0);
k = li_std_auto_ptr.makeNullAutoPtr();
assert(li_std_auto_ptr.is_nullptr(k));
delete(k);
assert(strcmp(li_std_auto_ptr.takeKlassAutoPtr([]), 'null smart pointer'));
