exec("swigtest.start", -1);

checkequal(call1(ADD_BY_VALUE_get(), 10, 11), 21, "ADD_BY_VALUE");
checkequal(call2(ADD_BY_POINTER_get(), 12, 13), 25, "ADD_BY_POINTER");
checkequal(call3(ADD_BY_REFERENCE_get(), 14, 15), 29, "ADD_BY_REFERENCE");

exec("swigtest.quit", -1);
