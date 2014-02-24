exec("swigtest.start", -1);

x = "hello";

// li_std_string tests

// Function tests

if test_ccvalue(x) <> x then swigtesterror(); end
if test_cvalue(x) <> x then swigtesterror(); end
if test_value(x) <> x then swigtesterror(); end

if test_const_reference(x) <> x then swigtesterror(); end
if test_reference_input(x) <> x then swigtesterror(); end
if test_reference_inout(x) <> x+x then swigtesterror(); end

//if test_reference_out() <> "test_reference_out message" then swigtesterror(); end
//if test_const_pointer_out() <> "x" then swigtesterror(); end

s = "initial string";

// Global variable tests

if GlobalString2_get() <> "global string 2" then swigtesterror(); end
GlobalString2_set(s);
if GlobalString2_get() <> s then swigtesterror(); end

if ConstGlobalString_get() <> "const global string" then swigtesterror(); end

// Member variable tests

myStructure = new_Structure();
if Structure_Str2_get(myStructure) <> "member string 2" then swigtesterror(); end

Structure_Str2_set(myStructure, s);
if Structure_Str2_get(myStructure) <> s then swigtesterror(); end

if Structure_ConstStr_get(myStructure) <> "const member string" then swigtesterror(); end

if Structure_StaticStr2_get() <> "static member string 2" then swigtesterror(); end

Structure_StaticStr2_set(s);
if Structure_StaticStr2_get() <> s then swigtesterror(); end

if Structure_ConstStaticStr_get() <> "const static member string" then swigtesterror(); end


if stdstring_empty() <> "" then swigtesterror(); end
if c_empty() <> "" then swigtesterror(); end


// li_std_string_extra tests

//if test_value_basic1(x) <> x then swigtesterror(); end
//if test_value_basic2(x) <> x then swigtesterror(); end
//if test_value_basic3(x) <> x then swigtesterror(); end

exec("swigtest.quit", -1);
