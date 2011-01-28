exec("swigtest.start", -1);

try
    foo = new_Foo();
catch
    swigtesterror();
end

if Foo_x_get(foo)<>0 then swigtesterror(); end
if typeof(Foo_x_get(foo))<>"constant" then swigtesterror(); end

if Foo_y_get(foo)<>0 then swigtesterror(); end
if typeof(Foo_y_get(foo))<>"constant" then swigtesterror(); end

if Foo_z_get(foo)<>0 then swigtesterror(); end
if typeof(Foo_z_get(foo))<>"constant" then swigtesterror(); end

if Foo_f_get(foo)<>uint32(0) then swigtesterror(); end
if typeof(Foo_f_get(foo))<>"uint32" then swigtesterror(); end

if Foo_seq_get(foo)<>uint32(0) then swigtesterror(); end
if typeof(Foo_seq_get(foo))<>"uint32" then swigtesterror(); end

try
    Foo_x_set(foo, 5);
catch
    swigtesterror();
end
if Foo_x_get(foo)<>5 then swigtesterror(); end

try
    Foo_y_set(foo, 5);
catch
    swigtesterror();
end
if Foo_y_get(foo)<>5 then swigtesterror(); end

try
    Foo_f_set(foo, 5);
catch
    swigtesterror();
end
if Foo_y_get(foo)<>uint32(5) then swigtesterror(); end

try
    Foo_z_set(foo, 13);
catch
    swigtesterror();
end
if Foo_z_get(foo)<>13 then swigtesterror(); end

try
    Foo_seq_set(foo, 3);
catch
    swigtesterror();
end
if Foo_seq_get(foo)<>uint32(3) then swigtesterror(); end

try
    delete_Foo(foo);
catch
    swigtesterror();
end

exec("swigtest.quit", -1);
