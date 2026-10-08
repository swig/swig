f1 = constructor_copy.Foo1(3);
f11 = constructor_copy.Foo1(f1);


if (f1.x ~= f11.x)
    error
end


f8 = constructor_copy.Foo8();
try
    f81 = constructor_copy.Foo8(f8);
    good = 0;
catch
    good = 1;
end

if (~good)
    error
end


bi = constructor_copy.Bari(5);
bc = constructor_copy.Bari(bi);

if (bi.x ~= bc.x)
    error
end


bd = constructor_copy.Bard(5);
try
    bc = constructor_copy.Bard(bd);
    good = 0;
catch
    good = 1;
end

if (~good)
    error
end
