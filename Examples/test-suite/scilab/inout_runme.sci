exec("swigtest.start", -1);

null = getNull();

a = AddOne1(10);
if a <> 11 then swigtesterror(); end

[a, b, c] = AddOne3(1, 2, 3);
if a <> 2 then swigtesterror(); end
if b <> 3 then swigtesterror(); end
if c <> 4 then swigtesterror(); end

a = AddOne1r(20);
if a <> 21 then swigtesterror(); end

[ret, out] = NonVoidOut(-42);
if ret <> null then swigtesterror(); end
if out <> 0 then swigtesterror(); end

exec("swigtest.quit", -1);
