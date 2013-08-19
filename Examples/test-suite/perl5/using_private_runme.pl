use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('using_private') }
require_ok('using_private');

my $f = using_private::FooBar->new();
$f->{x} = 3;

is($f->blah(4), 4, "blah(int)");

is($f->defaulted(), -1, "defaulted()");

is($f->defaulted(222), 222, "defaulted(222)");
