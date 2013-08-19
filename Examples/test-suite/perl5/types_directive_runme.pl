use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('types_directive') }
require_ok('types_directive');

my $d1 = types_directive::Time1->new(2001, 2, 3, 60);
my $newDate = types_directive::add($d1, 7);  # check that a Time1 instance is accepted where Date is expected
is($newDate->{day}, 10);

my $d2 = types_directive::Time2->new(1999, 8, 7, 60);
$newDate = types_directive::add($d2, 7); # check that a Time2 instance is accepted where Date is expected
is($newDate->{day}, 14);
