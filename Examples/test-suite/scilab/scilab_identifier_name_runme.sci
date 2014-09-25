exec("swigtest.start", -1);

// Not truncated identifier names
gvar_identifier_name_set(-101);
checkequal(gvar_identifier_name_get(), -101, "gvar_identifier_name_get()");
checkequal(CONS_IDENTIFIER_NAME_get(), -11, "CONS_IDENTIFIER_NAME_get()");
checkequal(function_identifier_name(), -21, "function_identifier_name()");

// Truncated identifier names
too_long_gvar_identi_set(101);
checkequal(too_long_gvar_identi_get(), 101, "too_long_variable_id_get()");
checkequal(TOO_LONG_CONST_IDENT_get(), 11, "TOO_LONG_CONST_IDENT_get()");
checkequal(too_long_function_identi(), 21, "too_long_function_identi()");

// Test identifier names in scilabconst mode
checkequal(SC_CONST_IDENTIFIER_NAME, int32(-12), "SC_TOO_LONG_IDENTIF");
checkequal(SC_TOO_LONG_CONST_IDENTI, int32(14), "SC_TOO_LONG_IDENTIF");

exec("swigtest.quit", -1);
