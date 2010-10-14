exec("swigtest.start", -1);

try
    a = get_test();
catch
    swigtesterror();
end

if test_myInt_get(a) <> 100 then swigtesterror(); end

if test_myShort_get(a) != 200 then swigtesterror(); end

exec("swigtest.quit", -1);