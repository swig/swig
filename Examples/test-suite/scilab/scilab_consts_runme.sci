exec("swigtest.start", -1);

function checkConst(const_val, expected_type, expected_const_val)    
  if typeof(const_val) <> expected_type then swigtesterror(); end
  if const_val <> expected_const_val then swigtesterror(); end
endfunction

checkConst(ICONST0_get(), "constant", 42);
checkConst(FCONST0_get(), "constant", 2.1828);
checkConst(CCONST0_get(), "string", "x");
//checkConst(CCONST0_2_get(), "string", "\n");
checkConst(SCONST0_get(), "string", "Hello World");
checkConst(SCONST0_2_get(), "string", """Hello World""");
checkConst(EXPR0_get(), "constant", 48.5484);
checkConst(iconst0_get(), "constant", 37);
checkConst(fconst0_get(), "constant", 42.2);

if isdef('BAR0') then swigtesterror(); end

checkConst(ICONST1, "int32", 42);
checkConst(FCONST1, "constant", 2.1828);
checkConst(CCONST1, "string", "x");
//checkConst(CCONST1_2, "string", "\n");
checkConst(SCONST1, "string", "Hello World");
checkConst(SCONST1_2, "string", """Hello World""");
checkConst(EXPR1, "constant", 48.5484);
checkConst(iconst0_get(), "constant", 37);
checkConst(fconst0_get(), "constant", 42.2);

if isdef('BAR1') then swigtesterror(); end

exec("swigtest.quit", -1);
