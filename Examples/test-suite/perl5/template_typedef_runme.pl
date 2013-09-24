use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok('template_typedef') }
require_ok('template_typedef');

my $d = template_typedef::make_Identity_float();
like(ref($d), qr/^template_typedef::/);
my $c = template_typedef::make_Identity_reald();
like(ref($c), qr/^template_typedef::/);

my $e = template_typedef::make_Multiplies_float_float_float_float($d, $d);
like(ref($e), qr/^template_typedef::/);

my $f = template_typedef::make_Multiplies_reald_reald_reald_reald($c, $c);
like(ref($f), qr/^template_typedef::/);

my $g = template_typedef::make_Multiplies_float_float_reald_reald($d, $c);
like(ref($g), qr/^template_typedef::/);
