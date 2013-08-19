use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('template_construct') }
require_ok('template_construct');

my $f = template_construct::Foo_int->new(3);
isa_ok($f, 'template_construct::Foo_int');
