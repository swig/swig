f = using_protected.FooBar();
f.x(3);

if (f.blah(4) ~= 4)
    error('blah(int)')
end
