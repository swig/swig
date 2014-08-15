import smart_pointer_overload.*

f = Foo();
b = Bar(f);


if (f.test(3) ~= 1)
    error
end
if (f.test(3.5) ~= 2)
    error
end
if (f.test('hello') ~= 3)
    error
end

if (b.test(3) ~= 1)
    error
end
if (b.test(3.5) ~= 2)
    error
end
if (b.test('hello') ~= 3)
    error
end


