import smart_pointer_rename.*

f = Foo();
b = Bar(f);

if (b.test() ~= 3)
    error
end

if (b.ftest1(1) ~= 1)
    error
end

if (b.ftest2(2,3) ~= 2)
    error
end

