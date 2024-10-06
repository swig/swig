exec("swigtest.start", -1);

null = getNull();

a = AddOne1(10);
if a <> 11 then swigtesterror(); end

[a, b, c] = AddOne3(10, 20, 30);
if a <> 11 then swigtesterror(); end
if b <> 21 then swigtesterror(); end
if c <> 31 then swigtesterror(); end

a = AddOne1r(20);
if a <> 21 then swigtesterror(); end

[ret, out] = NonVoidOut(-42);
if ret <> null then swigtesterror(); end
if out <> 0 then swigtesterror(); end

exec("swigtest.quit", -1);
