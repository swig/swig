use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('template_opaque') }
require_ok('template_opaque');

my $v = template_opaque::OpaqueVectorType->new(10);
isa_ok($v, 'template_opaque::OpaqueVectorType');
is($v->size(), 10);

template_opaque::FillVector($v);
