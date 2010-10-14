exec("swigtest.start", -1);

try
    a = get_test();
catch
    swigtesterror();
end

// Test default values
if test_myInt_get(a) <> 100 then swigtesterror(); end
if test_myShort_get(a) <> 200 then swigtesterror(); end

// Write new values
try
    test_myInt_set(a, 42)
    test_myShort_set(a, 12)
catch
    swigtesterror();
end

// Read new values
if test_myInt_get(a) <> 42 then swigtesterror(); end
if test_myShort_get(a) <> 12 then swigtesterror(); end

// Destroy pointer
delete_test(a);

exec("swigtest.quit", -1);
