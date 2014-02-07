exec("swigtest.start", -1);

test_set(APPLE_get());
if test_get() <> APPLE_get() then swigtesterror(); end

test_set(PEAR_get());
if test_get() <> PEAR_get() then swigtesterror(); end

exec("swigtest.quit", -1);
