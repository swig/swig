import overload_subtype.*

f = Foo();
b = Bar();

if (spam(f) ~= 1)
    error('foo')
end

if (spam(b) ~= 2)
    error('bar')
end

