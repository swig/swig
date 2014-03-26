exec("swigtest.start", -1);

globalfunc();

f = new_Foo();
Foo_memberfunc(f);

Foo_staticmemberfunc();

v1 = vfunc1(f);
if ~equalvoidptr(vfunc1(f), f) then swigtesterror("vfunc1(f) <> f"); end

if ~equalvoidptr(vfunc2(f), f) then swigtesterror("vfunc2(f) <> f"); end

v3 = vfunc3(v1);
if ~equalvoidptr(v3, f) then swigtesterror("vfunc3(v1) <> f"); end

Foo_memberfunc(v3);

exec("swigtest.quit", -1);

