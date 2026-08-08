exec("swigtest.start", -1);

// Multicharacter constants have type int, not char.
if MULTICHAR_AB_get() <> imulti_ab_get() then swigtesterror(); end

exec("swigtest.quit", -1);
