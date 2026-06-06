var reference_global_vars = require("reference_global_vars");

// const class reference variable
if (reference_global_vars.getconstTC().num != 33) {
    throw new Error;
}

// primitive reference variables
reference_global_vars.var_bool = reference_global_vars.createref_bool(false);
if (reference_global_vars.value_bool(reference_global_vars.var_bool) != false) {
    throw new Error;
}

reference_global_vars.var_bool = reference_global_vars.createref_bool(true);
if (reference_global_vars.value_bool(reference_global_vars.var_bool) != true) {
    throw new Error;
}

reference_global_vars.var_char = reference_global_vars.createref_char("w");
if (reference_global_vars.value_char(reference_global_vars.var_char) != "w") {
    throw new Error;
}

reference_global_vars.var_unsigned_char = reference_global_vars.createref_unsigned_char(10);
if (reference_global_vars.value_unsigned_char(reference_global_vars.var_unsigned_char) != 10) {
    throw new Error;
}

reference_global_vars.var_signed_char = reference_global_vars.createref_signed_char(10);
if (reference_global_vars.value_signed_char(reference_global_vars.var_signed_char) != 10) {
    throw new Error;
}

reference_global_vars.var_short = reference_global_vars.createref_short(10);
if (reference_global_vars.value_short(reference_global_vars.var_short) != 10) {
    throw new Error;
}

reference_global_vars.var_unsigned_short = reference_global_vars.createref_unsigned_short(10);
if (reference_global_vars.value_unsigned_short(reference_global_vars.var_unsigned_short) != 10) {
    throw new Error;
}

reference_global_vars.var_int = reference_global_vars.createref_int(10);
if (reference_global_vars.value_int(reference_global_vars.var_int) != 10) {
    throw new Error;
}

reference_global_vars.var_unsigned_int = reference_global_vars.createref_unsigned_int(10);
if (reference_global_vars.value_unsigned_int(reference_global_vars.var_unsigned_int) != 10) {
    throw new Error;
}

reference_global_vars.var_long = reference_global_vars.createref_long(10);
if (reference_global_vars.value_long(reference_global_vars.var_long) != 10) {
    throw new Error;
}

reference_global_vars.var_unsigned_long = reference_global_vars.createref_unsigned_long(10);
if (reference_global_vars.value_unsigned_long(reference_global_vars.var_unsigned_long) != 10) {
    throw new Error;
}

reference_global_vars.var_long_long = reference_global_vars.createref_long_long(0x6FFFFFFFFFFFFFF8);
if (reference_global_vars.value_long_long(reference_global_vars.var_long_long) != 0x6FFFFFFFFFFFFFF8) {
    throw new Error;
}

//ull = abs(0xFFFFFFF2FFFFFFF0)
ull = 55834574864;
reference_global_vars.var_unsigned_long_long = reference_global_vars.createref_unsigned_long_long(ull);
if (reference_global_vars.value_unsigned_long_long(reference_global_vars.var_unsigned_long_long) != ull) {
    throw new Error;
}

reference_global_vars.var_float = reference_global_vars.createref_float(10.5);
if (reference_global_vars.value_float(reference_global_vars.var_float) != 10.5) {
    throw new Error;
}

reference_global_vars.var_double = reference_global_vars.createref_double(10.5);
if (reference_global_vars.value_double(reference_global_vars.var_double) != 10.5) {
    throw new Error;
}

// class reference variable
reference_global_vars.var_TestClass = reference_global_vars.createref_TestClass(new reference_global_vars.TestClass(20));
if (reference_global_vars.value_TestClass(reference_global_vars.var_TestClass).num != 20) {
    throw new Error;
}
