use strict;
use warnings;
use Test::More tests => 14;
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

# Getting a pointer global after setting it to undef or after a failed set crashed
$global_vars::xp = undef;
ok(defined $global_vars::xp, "pointer global set to undef");
eval { $global_vars::xp = 42 };
like($@, qr/TypeError/, "pointer global set to a number");
ok(defined $global_vars::xp, "pointer global after a failed set");

# Reading a pointer global changed a pointer object assigned to it, after the global changed in C or after a failed set
my $xref = $global_vars::c_member;
my $xref_value = $$xref;
$global_vars::xp = $xref;
global_vars::clear_xp();
is(${$global_vars::xp}, 0, "pointer global changed in C");
is($$xref, $xref_value, "pointer object assigned to the global unchanged");
my $hp = $global_vars::hr;
my $hp_value = $$hp;
eval { $global_vars::xp = $hp };
like($@, qr/TypeError/, "pointer global set to a pointer of another type");
is(${$global_vars::xp}, 0, "pointer global after a failed set");
is($$hp, $hp_value, "pointer object of another type unchanged");
