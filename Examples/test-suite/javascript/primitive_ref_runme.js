var primitive_ref = require("primitive_ref");

if (primitive_ref.ref_int(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_uint(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_short(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_ushort(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_long(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_ulong(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_schar(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_uchar(3) != 3) {
    throw new Error
}

if (primitive_ref.ref_float(3.5) != 3.5) {
    throw new Error
}

if (primitive_ref.ref_double(3.5) != 3.5) {
    throw new Error
}

if (primitive_ref.ref_bool(true) != true) {
    throw new Error
}

if (primitive_ref.ref_char("x") != "x") {
    throw new Error
}

if (primitive_ref.ref_over(0) != 0) {
    throw new Error
}
