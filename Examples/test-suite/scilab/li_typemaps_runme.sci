exec("swigtest.start", -1);


// double
if (in_double(22.22) <> 22.22) then swigtesterror(); end
if (inr_double(22.22) <> 22.22) then swigtesterror(); end
if (out_double(22.22) <> 22.22) then swigtesterror(); end
if (outr_double(22.22) <> 22.22) then swigtesterror(); end
if (inout_double(22.22) <> 22.22) then swigtesterror(); end
if (inoutr_double(22.22) <> 22.22) then swigtesterror(); end

// signed char
if (in_schar(22) <> 22) then swigtesterror(); end
if (inr_schar(22) <> 22) then swigtesterror(); end
if (out_schar(22) <> 22) then swigtesterror(); end
if (outr_schar(22) <> 22) then swigtesterror(); end
if (inoutr_schar(22) <> 22) then swigtesterror(); end

// unsigned char
if (in_uchar(uint8(22)) <> uint8(22)) then swigtesterror(); end
if (inr_uchar(uint8(22)) <> uint8(22)) then swigtesterror(); end
if (out_uchar(uint8(22)) <> uint8(22)) then swigtesterror(); end
if (outr_uchar(uint8(22)) <> uint8(22)) then swigtesterror(); end
if (inoutr_uchar(uint8(22)) <> uint8(22)) then swigtesterror(); end

// short
if (in_short(22) <> 22) then swigtesterror(); end
if (inr_short(22) <> 22) then swigtesterror(); end
if (out_short(22) <> 22) then swigtesterror(); end
if (outr_short(22) <> 22) then swigtesterror(); end
if (inout_short(22) <> 22) then swigtesterror(); end
if (inoutr_short(22) <> 22) then swigtesterror(); end

// unsigned short
if (in_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end
if (inr_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end
if (out_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end
if (outr_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end
if (inout_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end
if (inoutr_ushort(uint16(22)) <> uint16(22)) then swigtesterror(); end

// int
if (in_int(22) <> 22) then swigtesterror(); end
if (inr_int(22) <> 22) then swigtesterror(); end
if (out_int(22) <> 22) then swigtesterror(); end
if (outr_int(22) <> 22) then swigtesterror(); end
if (inout_int(22) <> 22) then swigtesterror(); end
if (inoutr_int(22) <> 22) then swigtesterror(); end

// unsigned int
if (in_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inr_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (out_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (outr_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inout_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inoutr_uint(uint32(22)) <> uint32(22)) then swigtesterror(); end

// long
if (in_long(22) <> 22) then swigtesterror(); end
if (inr_long(22) <> 22) then swigtesterror(); end
if (out_long(22) <> 22) then swigtesterror(); end
if (outr_long(22) <> 22) then swigtesterror(); end
if (inout_long(22) <> 22) then swigtesterror(); end
if (inoutr_long(22) <> 22) then swigtesterror(); end

// unsigned long
if (in_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inr_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (out_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (outr_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inout_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end
if (inoutr_ulong(uint32(22)) <> uint32(22)) then swigtesterror(); end

// bool
if (in_bool(%t) <> %t) then swigtesterror(); end
if (inr_bool(%f) <> %f) then swigtesterror(); end
if (out_bool(%t) <> %t) then swigtesterror(); end
if (outr_bool(%f) <> %f) then swigtesterror(); end
if (inout_bool(%t) <> %t) then swigtesterror(); end
if (inoutr_bool(%f) <> %f) then swigtesterror(); end

// float
//if (in_float(22.22) <> 22.22) then swigtesterror(); end
//if (inr_float(22.22) <> 22.22) then swigtesterror(); end
//if (out_float(22.22) <> 22.22) then swigtesterror(); end
//if (outr_float(22.22) <> 22.22) then swigtesterror(); end
//if (inout_float(22.22) <> 22.22) then swigtesterror(); end
//if (inoutr_float(22.22) <> 22.22) then swigtesterror(); end

// long long
//if (in_longlong(22) <> 22) then swigtesterror(); end
//if (inr_longlong(22) <> 22) then swigtesterror(); end
//if (out_longlong(22) <> 22) then swigtesterror(); end
//if (outr_longlong(22) <> 22) then swigtesterror(); end
//if (inout_longlong(22) <> 22) then swigtesterror(); end
//if (inoutr_longlong(22) <> 22) then swigtesterror(); end

// unsigned long long
//if (in_ulonglong(uint64(22)) <> 22) then swigtesterror(); end
//if (inr_ulonglong(uint64(22)) <> 22) then swigtesterror(); end
//if (out_ulonglong(uint64(22)) <> 22) then swigtesterror(); end
//if (outr_ulonglong(uint64(22)) <> 22) then swigtesterror(); end
//if (inout_ulonglong(uint64(22)) <> 22) then swigtesterror(); end
//if (inoutr_ulonglong(uint64(22)) <> 22) then swigtesterror(); end

// the others
//a,b = inoutr_int2(1, 2);
//if (a<>1 || b<>2) then swigtesterror(); end
//f,i = out_foo(10)
//if (f.a <> 10 || i <> 20) then swigtesterror(); end

exec("swigtest.quit", -1);
