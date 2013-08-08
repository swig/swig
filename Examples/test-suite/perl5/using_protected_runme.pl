use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('using_protected') }
require_ok('using_protected');

my $f = using_protected::FooBar->new();
$f->{x} = 3;

is($f->blah(4), 4, "blah(int)");
