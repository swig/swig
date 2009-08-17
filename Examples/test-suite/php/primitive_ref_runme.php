<?php

require "tests.php";
require "primitive_ref.php";

check::equal(ref_over(3), 3, "ref_over failed");

check::equal(ref_int(3), 3, "ref_int failed");
check::equal(ref_uint(3), 3, "ref_uint failed");
check::equal(ref_short(3), 3, "ref_short failed");
check::equal(ref_ushort(3), 3, "ref_ushort failed");
check::equal(ref_long(3), 3, "ref_long failed");
check::equal(ref_ulong(3), 3, "ref_ulong failed");
check::equal(ref_schar(3), 3, "ref_schar failed");
check::equal(ref_uchar(3), 3, "ref_uchar failed");
check::equal(ref_bool(true), true, "ref_bool failed");
check::equal(ref_float(3.5), 3.5, "ref_float failed");
check::equal(ref_double(3.5), 3.5, "ref_double failed");
check::equal(ref_char('x'), 'x', "ref_char failed");
//check::equal(ref_longlong(0x123456789ABCDEF0), 0x123456789ABCDEF0, "ref_longlong failed");
//check::equal(ref_ulonglong(0xF23456789ABCDEF0), 0xF23456789ABCDEF0, "ref_ulonglong failed");
printf("TODO: long long and unsigned long long const reference typemaps\n");

check::done();
?>
