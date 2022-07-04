use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('cpp11_std_unique_ptr') }
require_ok('cpp11_std_unique_ptr');

my $k1 = cpp11_std_unique_ptr::makeKlassUniquePtr("first");
my $k2 = cpp11_std_unique_ptr::makeKlassUniquePtr("second");
is(cpp11_std_unique_ptr::Klass::getTotal_count, 2, "have 2 pointers");

undef $k1;
is(cpp11_std_unique_ptr::Klass::getTotal_count, 1, "left 1 pointer");

is($k2->getLabel, "second", "proper label");

undef $k2;
is(cpp11_std_unique_ptr::Klass::getTotal_count, 0, "remove all pointers");
