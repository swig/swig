a = template_inherit.FooInt();
b = template_inherit.FooDouble();
c = template_inherit.BarInt();
d = template_inherit.BarDouble();
e = template_inherit.FooUInt();
f = template_inherit.BarUInt();

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

if (~strcmp(template_inherit.invoke_blah_int(a),'Foo'))
    error
end

if (~strcmp(template_inherit.invoke_blah_int(c),'Bar'))
    error
end

if (~strcmp(template_inherit.invoke_blah_double(b),'Foo'))
    error
end

if (~strcmp(template_inherit.invoke_blah_double(d),'Bar'))
    error
end

if (~strcmp(template_inherit.invoke_blah_uint(e),'Foo'))
    error
end

if (~strcmp(template_inherit.invoke_blah_uint(f),'Bar'))
    error
end

