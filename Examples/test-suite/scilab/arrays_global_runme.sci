exec("swigtest.start", -1);

if array_const_i_get() <> [10, 20] then swingtesterror(); end

if BeginString_FIX44a_get() <> "FIX.a.a" then swingtesterror(); end
if BeginString_FIX44b_get() <> "FIX.b.b" then swingtesterror(); end
if BeginString_FIX44c_get() <> "FIX.c.c" then swingtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swingtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swingtesterror(); end
BeginString_FIX44b_set(strcat(["12","\0","45"]));
if BeginString_FIX44b_get() <> "12\045" then swingtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swingtesterror(); end
if BeginString_FIX44e_get() <> "FIX.e.e" then swingtesterror(); end
if BeginString_FIX44f_get() <> "FIX.f.f" then swingtesterror(); end

if test_a("hello","hi","chello","chi") <> "hi" then swingtesterror(); end

if test_b("1234567","hi") <> "1234567" then swingtesterror(); end

exec("swigtest.quit", -1);
