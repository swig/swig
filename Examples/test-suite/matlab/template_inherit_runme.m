import template_inherit.*
a = FooInt();
b = FooDouble();
c = BarInt();
d = BarDouble();
e = FooUInt();
f = BarUInt();

if (~strcmp(a.blah(),'Foo'))
    error
end

if (~strcmp(b.blah(),'Foo'))
    error
end

if (~strcmp(e.blah(),'Foo'))
    error
end

if (~strcmp(c.blah(),'Bar'))
    error
end

if (~strcmp(d.blah(),'Bar'))
    error
end

if (~strcmp(f.blah(),'Bar'))
    error
end

if (~strcmp(c.foomethod(),'foomethod'))
    error
end

if (~strcmp(d.foomethod(),'foomethod'))
    error
end

if (~strcmp(f.foomethod(),'foomethod'))
    error
end

if (~strcmp(invoke_blah_int(a),'Foo'))
    error
end

if (~strcmp(invoke_blah_int(c),'Bar'))
    error
end

if (~strcmp(invoke_blah_double(b),'Foo'))
    error
end

if (~strcmp(invoke_blah_double(d),'Bar'))
    error
end

if (~strcmp(invoke_blah_uint(e),'Foo'))
    error
end

if (~strcmp(invoke_blah_uint(f),'Bar'))
    error
end

