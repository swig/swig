use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('cpp11_strongly_typed_enumerations_perl_const') }
require_ok('cpp11_strongly_typed_enumerations_perl_const');

is(cpp11_strongly_typed_enumerations_perl_const::Enum18::Val1, 1181);
is(cpp11_strongly_typed_enumerations_perl_const::Enum18::Val2, 1182);
