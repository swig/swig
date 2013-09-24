use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('smart_pointer_templatevariables') }
require_ok('smart_pointer_templatevariables');

my $d = smart_pointer_templatevariables::DiffImContainerPtr_D->new(
    smart_pointer_templatevariables::create(1234, 5678));

is($d->{id}, 1234);
$d->{id} = 4321;
is($d->{id}, 4321);
