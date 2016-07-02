f = using_private.FooBar();
f.x(3);

if (f.blah(4) ~= 4)
    error, 'blah(int)'
end

if (f.defaulted() ~= -1)
    error, 'defaulted()'
end

if (f.defaulted(222) ~= 222)
    error, 'defaulted(222)'
end
