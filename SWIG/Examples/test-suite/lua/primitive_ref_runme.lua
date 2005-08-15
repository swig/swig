require("import")	-- the import fn
import("primitive_ref",true)	-- import code into global namespace

assert(ref_int(3)==3)

assert(ref_uint(3) == 3)

assert(ref_short(3) == 3)

assert(ref_ushort(3) == 3)

assert(ref_long(3) == 3)

assert(ref_ulong(3) == 3)

assert(ref_schar(3) == 3)

assert(ref_uchar(3) == 3)

assert(ref_float(3.5) == 3.5)

assert(ref_double(3.5) == 3.5)

assert(ref_bool(true) == true)

assert(ref_char('x') == 'x')

assert(ref_over(0) == 0)

a=A(12)
assert(ref_over(a)==12)
