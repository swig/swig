exec("swigtest.start", -1);

v = getversion("scilab");

// Test truncating variables, constants, functions identifier names in Scilab 5
// not truncated
gvar_identifier_name_set(-101);
checkequal(gvar_identifier_name_get(), -101, "gvar_identifier_name_get()");
checkequal(CONS_IDENTIFIER_NAME_get(), -11, "CONS_IDENTIFIER_NAME_get()");
checkequal(function_identifier_name(), -21, "function_identifier_name()");

// truncated in Scilab 5
if v(1) < 6 then
too_long_gvar_identi_set(101);
checkequal(too_long_gvar_identi_get(), 101, "too_long_variable_id_get()");
checkequal(TOO_LONG_CONST_IDENT_get(), 11, "TOO_LONG_CONST_IDENTIFIER_NAME_1_get");
checkequal(too_long_function_identi(), 21, "too_long_function_identifier_name_1()");
else
too_long_gvar_identifier_name_1_set(101);
checkequal(too_long_gvar_identifier_name_1_get(), 101, "too_long_variable_id_get()");
checkequal(TOO_LONG_CONST_IDENTIFIER_NAME_1_get(), 11, "TOO_LONG_CONST_IDENTIFIER_NAME_1_get");
checkequal(too_long_function_identifier_name_1(), 21, "too_long_function_identifier_name_1()");
end

// Test truncating when %scilabconst mode is activated
checkequal(SC_CONST_IDENTIFIER_NAME, int32(-12), "SC_CONST_IDENTIFIER_NAME");
if v(1) < 6 then
checkequal(SC_TOO_LONG_CONST_IDENTI, int32(14), "SC_TOO_LONG_CONST_IDENTIFIER_NAME_2");
else
checkequal(SC_TOO_LONG_CONST_IDENTIFIER_NAME_2, int32(14), "SC_TOO_LONG_CONST_IDENTIFIER_NAME_2");
end

// Test truncating in the case of struct
st = new_st();
st_m_identifier_name_set(st, 15);
checkequal(st_m_identifier_name_get(st), 15, "st_m_identifier_name_get(st)");
if v(1) < 6 then
st_too_long_member_i_set(st, 25);
checkequal(st_too_long_member_i_get(st), 25, "st_too_long_member_identifier_name_get(st)");
else
st_too_long_member_identifier_name_set(st, 25);
checkequal(st_too_long_member_identifier_name_get(st), 25, "st_too_long_member_identifier_name_get(st)");
end
delete_st(st);

exec("swigtest.quit", -1);
