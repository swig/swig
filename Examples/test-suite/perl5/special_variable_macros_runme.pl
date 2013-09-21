use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok('special_variable_macros') }
require_ok('special_variable_macros');

my $name = special_variable_macros::Name->new();
is(special_variable_macros::testFred($name), 'none');
is(special_variable_macros::testJack($name), '$specialname');
is(special_variable_macros::testJill($name), 'jilly');
is(special_variable_macros::testMary($name), 'SWIGTYPE_p_NameWrap');
is(special_variable_macros::testJames($name), 'SWIGTYPE_Name');
is(special_variable_macros::testJim($name), 'multiname num');
my $pib = special_variable_macros::PairIntBool->new(10, undef);
is(special_variable_macros::testJohn($pib), 123);

