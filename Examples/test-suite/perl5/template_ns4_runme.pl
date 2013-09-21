use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('template_ns4') }
require_ok('template_ns4');

my $d = template_ns4::make_Class_DD();
is($d->test(), 'test');
