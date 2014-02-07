exec("swigtest.start", -1);

// Check passing by value

if (val_double(42) <> 42) then swigtesterror(); end
if (val_float(42) <> 42) then swigtesterror(); end

if (val_char('a') <> 'a') then swigtesterror(); end
if (val_schar(42) <> 42) then swigtesterror(); end
if (val_schar(int8(42)) <> 42) then swigtesterror(); end
if (val_uchar(uint8(42)) <> uint8(42)) then swigtesterror(); end

if (val_short(42) <> 42) then swigtesterror(); end
if (val_short(int16(42)) <> 42) then swigtesterror(); end
if (val_ushort(uint16(42)) <> uint16(42)) then swigtesterror(); end

if (val_int(42) <> 42) then swigtesterror(); end
if (val_int(int32(42)) <> 42) then swigtesterror(); end
if (val_uint(uint32(42)) <> uint32(42)) then swigtesterror(); end

if (val_long(42) <> 42) then swigtesterror(); end
if (val_long(int32(42)) <> 42) then swigtesterror(); end
if (val_ulong(uint32(42)) <> uint32(42)) then swigtesterror(); end

if (val_bool(%t) <> %t) then swigtesterror(); end
//if (val_bool(1) <> %t) then swigtesterror(); end

//if (val_llong(42) <> 42) then swigtesterror(); end
//if (val_llong(int64(42)) <> 42) then swigtesterror(); end
//if (val_ullong(uint64(42)) <> uint64(42)) then swigtesterror(); end

// Check passing by reference
//if (ref_float(42) <> 42) then swigtesterror(); end
//if (ref_double(42) <> 42) then swigtesterror(); end

if (ref_char('a') <> 'a') then swigtesterror(); end
if (ref_schar(42) <> 42) then swigtesterror(); end
if (ref_schar(int8(42)) <> 42) then swigtesterror(); end
if (ref_uchar(uint8(42)) <> uint8(42)) then swigtesterror(); end

if (ref_short(42) <> 42) then swigtesterror(); end
if (ref_short(int16(42)) <> 42) then swigtesterror(); end
if (ref_ushort(uint16(42)) <> uint16(42)) then swigtesterror(); end

if (ref_int(42) <> 42) then swigtesterror(); end
if (ref_int(int32(42)) <> 42) then swigtesterror(); end
if (ref_uint(uint32(42)) <> uint32(42)) then swigtesterror(); end

if (ref_long(42) <> 42) then swigtesterror(); end
if (ref_long(int32(42)) <> 42) then swigtesterror(); end
if (ref_ulong(uint32(42)) <> uint32(42)) then swigtesterror(); end

if (ref_bool(%t) <> %t) then swigtesterror(); end
//if (ref_bool(1) <> %t) then swigtesterror(); end

//if (ref_llong(42) <> 42) then swigtesterror(); end
//if (ref_llong(int64(42)) <> 42) then swigtesterror(); end
//if (ref_ullong(42) <> 42) then swigtesterror(); end
//if (ref_ullong(uint64(42)) <> uint64(42)) then swigtesterror(); end


exec("swigtest.quit", -1);
