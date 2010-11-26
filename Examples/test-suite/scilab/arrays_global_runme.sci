exec("swigtest.start", -1);

if array_const_i_get() <> [10, 20] then swigtesterror(); end

if BeginString_FIX44a_get() <> "FIX.a.a" then swigtesterror(); end
if BeginString_FIX44b_get() <> "FIX.b.b" then swigtesterror(); end
if BeginString_FIX44c_get() <> "FIX.c.c" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
BeginString_FIX44b_set(strcat(["12","\0","45"]));
if BeginString_FIX44b_get() <> "12\045" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
if BeginString_FIX44e_get() <> "FIX.e.e" then swigtesterror(); end
if BeginString_FIX44f_get() <> "FIX.f.f" then swigtesterror(); end

if test_a("hello","hi","chello","chi") <> "hi" then swigtesterror(); end

if test_b("1234567","hi") <> "1234567" then swigtesterror(); end

exec("swigtest.quit", -1);
