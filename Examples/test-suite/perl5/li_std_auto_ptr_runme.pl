use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('li_std_auto_ptr') }
require_ok('li_std_auto_ptr');

my $k1 = li_std_auto_ptr::makeKlassAutoPtr("first");
my $k2 = li_std_auto_ptr::makeKlassAutoPtr("second");
is(li_std_auto_ptr::Klass::getTotal_count, 2, "have 2 pointers");

undef $k1;
is(li_std_auto_ptr::Klass::getTotal_count, 1, "left 1 pointer");

is($k2->getLabel, "second", "proper label");

undef $k2;
is(li_std_auto_ptr::Klass::getTotal_count, 0, "remove all pointers");
