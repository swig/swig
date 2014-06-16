exec("swigtest.start", -1);

// bool
a = [%T %F %F %T %F %T %T %T];
checkequal(arr_bool(a, 8), 5, "arr_bool");

// char
a = ["charptr"]
checkequal(arr_char(a, 7), 756, "arr_char");

// signed char
a = int8([1, 2, 3, 4]);
checkequal(arr_schar(a, 4), 10, "arr_schar");

// unsigned char
a = uint8([1, 2, 3, 4]);
checkequal(arr_uchar(a, 4), 10, "arr_uchar");

// short
a = int16([1, 2, 3, 4]);
checkequal(arr_short(a, 4), 10, "arr_short");

// unsigned short
a = uint16([1, 2, 3, 4]);
checkequal(arr_ushort(a, 4), 10, "arr_ushort");

// int
a = int32([1, 2, 3, 4]);
checkequal(arr_int(a, 4), 10, "arr_int");

// unsigned int
a = uint32([1, 2, 3, 4]);
checkequal(arr_uint(a, 4), 10, "");

// long
a = [1, 2, 3, 4];
checkequal(arr_long(a, 4), 10, "arr_long");

// unsigned long
a = [1, 2, 3, 4];
checkequal(arr_ulong(uint32(a), 4), 10, "arr_ulong");

// long long
// No equivalent in Scilab 5

// unsigned long long
// No equivalent in Scilab 5

// float
a = [1, 2, 3, 4];
checkequal(arr_float(a, 4), 10, "arr_float");

// double
a = [1, 2, 3, 4];
checkequal(arr_double(a, 4), 10, "arr_double");

exec("swigtest.quit", -1);
