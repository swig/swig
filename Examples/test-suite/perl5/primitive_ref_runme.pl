use primitive_ref;

if (primitive_ref::ref_int(3) != 3) {
    die "ref_int failed!\n";
}
if (primitive_ref::ref_uint(3) != 3) {
    die "ref_uint failed!\n";
}
if (primitive_ref::ref_short(3) != 3) {
    die "ref_short failed!\n";
}
if (primitive_ref::ref_ushort(3) != 3) {
    die "ref_ushort failed!\n";
}
if (primitive_ref::ref_long(3) != 3) {
    die "ref_long failed!\n";
}
if (primitive_ref::ref_ulong(3) != 3) {
    die "ref_ulong failed!\n";
}
if (primitive_ref::ref_schar(3) != 3) {
    die "ref_schar failed!\n";
}
if (primitive_ref::ref_uchar(3) != 3) {
    die "ref_uchar failed!\n";
}
if (primitive_ref::ref_bool(1) != 1) {
    die "ref_bool failed!\n";
}
if (primitive_ref::ref_float(3.5) != 3.5) {
    die "ref_float failed!\n";
}
if (primitive_ref::ref_double(3.5) != 3.5) {
    die "ref_double failed!\n";
}
if (primitive_ref::ref_char('x') != 'x') {
    die "ref_char failed!\n";
}
