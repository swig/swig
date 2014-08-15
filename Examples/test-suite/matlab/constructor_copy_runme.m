import constructor_copy.*

f1 = Foo1(3);
f11 = Foo1(f1);


if (f1.x ~= f11.x)
    error
end


f8 = Foo8();
try
    f81 = Foo8(f8);
    good = 0;
catch
    good = 1;
end

if (~good)
    error
end


bi = Bari(5);
bc = Bari(bi);

if (bi.x ~= bc.x)
    error
end
    

bd = Bard(5);
try
    bc = Bard(bd);
    good = 0;
catch
    good = 1;
end

if (~good)
    error
end

