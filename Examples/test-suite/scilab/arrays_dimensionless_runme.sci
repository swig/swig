exec("swigtest.start", -1);

// bool
a = [%T %F %F %T %F %T %T %T];
if arr_bool(a, 8) <> 5 then swigtesterror(); end
if typeof(arr_bool(a, 8)) <> "constant" then swigtesterror(); end

// char
a = ["charptr"]
if arr_char(a, 7) <> 756 then swigtesterror(); end
if typeof(arr_char(a, 7)) <> "constant" then swigtesterror(); end

// signed char
a = int8([1, 2, 3, 4]);
if arr_schar(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_schar(a, 4)) <> "constant" then swigtesterror(); end

// unsigned char
a = uint8([1, 2, 3, 4]);
if arr_uchar(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_uchar(a, 4)) <> "constant" then swigtesterror(); end

// short
a = int16([1, 2, 3, 4]);
if arr_short(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_short(a, 4)) <> "constant" then swigtesterror(); end

// unsigned short
a = uint16([1, 2, 3, 4]);
if arr_ushort(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_ushort(a, 4)) <> "constant" then swigtesterror(); end

// int
a = int32([1, 2, 3, 4]);
if arr_int(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_int(a, 4)) <> "constant" then swigtesterror(); end

// unsigned int
a = uint32([1, 2, 3, 4]);
if arr_uint(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_uint(a, 4)) <> "constant" then swigtesterror(); end

// long
a = [1, 2, 3, 4];
if arr_long(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_long(a, 4)) <> "constant" then swigtesterror(); end

// unsigned long
a = [1, 2, 3, 4];
if arr_ulong(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_ulong(a, 4)) <> "constant" then swigtesterror(); end

// long long
// No equivalent in Scilab 5

// unsigned long long
// No equivalent in Scilab 5

// float
a = [1, 2, 3, 4];
if arr_float(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_float(a, 4)) <> "constant" then swigtesterror(); end

// double
a = [1, 2, 3, 4];
if arr_double(a, 4) <> 10 then swigtesterror(); end
if typeof(arr_double(a, 4)) <> "constant" then swigtesterror(); end

exec("swigtest.quit", -1);
