import overload_extendc.*

f = overload_extendc.Foo();
if (f.test(3) ~= 1)
    error('Failed!')
end
if (f.test('hello') ~= 2)
    error('Failed!')
end
if (f.test(3.5,2.5) ~= 3)
    error('Failed!')
end
if (f.test('hello',20) ~= 1020)
    error('Failed!')
end
if (f.test('hello',20,100) ~= 120)
    error('Failed!')
end

% C default args
if (f.test(f) ~= 30)
    error('Failed!')
end
if (f.test(f,100) ~= 120)
    error('Failed!')
end
if (f.test(f,100,200) ~= 300)
    error('Failed!')
end

