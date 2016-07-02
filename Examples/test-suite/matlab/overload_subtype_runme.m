f = overload_subtype.Foo();
b = overload_subtype.Bar();

if (overload_subtype.spam(f) ~= 1)
    error('foo')
end

if (overload_subtype.spam(b) ~= 2)
    error('bar')
end

