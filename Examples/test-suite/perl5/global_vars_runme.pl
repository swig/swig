use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('global_vars') }
require_ok('global_vars');

my $an = new global_vars::A();
isa_ok($an, 'global_vars::A');
$global_vars::ap = $an;
is($global_vars::ap, $an, "global var assignment");

# Regression test for https://sourceforge.net/p/swig/bugs/564/ - changing the
# value in C/C++ apparently wasn't reflected in Perl:
$global_vars::x = 17;
is($global_vars::x, 17, "global var assignment");
global_vars::init();
is($global_vars::x, 1234, "C++ global var change visible in Perl");
