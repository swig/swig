use strict;
use warnings;
use Test::More tests => 27;
BEGIN { use_ok('arrays_null') }
require_ok('arrays_null');

my $s = arrays_null::ArraysNull->new();
my $other = arrays_null::ArraysNull->new();
arrays_null::arrays_null_fill($other, 10);
$s->{ints} = $other->{ints};
$s->{items} = $other->{items};
$s->{grid} = $other->{grid};
is(arrays_null::arrays_null_check($s, 10), 1, "member set");

# Setting an array member or global variable to undef is an error, as there is nothing to copy from.
eval { $s->{ints} = undef };
like($@, qr/invalid null reference/, "ints member set to undef");
eval { $s->{items} = undef };
like($@, qr/invalid null reference/, "items member set to undef");
eval { $s->{grid} = undef };
like($@, qr/invalid null reference/, "grid member set to undef");
is(arrays_null::arrays_null_check($s, 10), 1, "member set to undef unchanged");

$arrays_null::arrays_null_ints = $s->{ints};
# A global array of a class is an unlinked tied hash in the proxy module, so it is set through the low level module.
$arrays_nullc::arrays_null_items = $s->{items};
$arrays_null::arrays_null_grid = $s->{grid};
is(arrays_null::arrays_null_globals_check(10), 1, "global set");

eval { $arrays_null::arrays_null_ints = undef };
like($@, qr/invalid null reference/, "ints global set to undef");
eval { $arrays_nullc::arrays_null_items = undef };
like($@, qr/invalid null reference/, "items global set to undef");
eval { $arrays_null::arrays_null_grid = undef };
like($@, qr/invalid null reference/, "grid global set to undef");
eval { $arrays_null::arrays_null_ints_ref = undef };
like($@, qr/invalid null reference/, "ints_ref global set to undef");
eval { $arrays_null::arrays_null_bools = undef };
like($@, qr/invalid null reference/, "bools global set to undef");
is(arrays_null::arrays_null_globals_check(10), 1, "global set to undef unchanged");

# undef is passed on as a NULL pointer for an array parameter.
is(arrays_null::arrays_null_ints_isnull(undef), 1, "ints parameter");
is(arrays_null::arrays_null_ints_unsized_isnull(undef), 1, "unsized ints parameter");
is(arrays_null::arrays_null_enums_isnull(undef), 1, "enums parameter");
is(arrays_null::arrays_null_enums_unsized_isnull(undef), 1, "unsized enums parameter");
is(arrays_null::arrays_null_items_isnull(undef), 1, "items parameter");
is(arrays_null::arrays_null_items_unsized_isnull(undef), 1, "unsized items parameter");
is(arrays_null::arrays_null_bools_isnull(undef), 1, "bools parameter");
is(arrays_null::arrays_null_bools_unsized_isnull(undef), 1, "unsized bools parameter");
is(arrays_null::arrays_null_chars_isnull(undef), 1, "chars parameter");
is(arrays_null::arrays_null_chars_unsized_isnull(undef), 1, "unsized chars parameter");
is(arrays_null::arrays_null_strings_isnull(undef), 1, "strings parameter");
is(arrays_null::arrays_null_strings_unsized_isnull(undef), 1, "unsized strings parameter");

# A reference to an array cannot be undef.
eval { arrays_null::arrays_null_ints_ref_first(undef) };
like($@, qr/invalid null reference/, "ints_ref parameter");
