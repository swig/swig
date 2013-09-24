use strict;
use warnings;
use Test::More tests => 38;
BEGIN { use_ok('bools') }
require_ok('bools');

my $obj = bools::BoolStructure->new();
isa_ok($obj, 'bools::BoolStructure');

sub check_val { my($ref, $val, $name) = @_;
  is(bools::bo($$ref), $val, "bo($name)");
}
sub check_var { my($ref, $val, $name, $const) = @_;
  is($$ref, $val, $name);
  check_val($ref, $val, $name);
}
sub check_ref { my($ref, $val, $name, $const) = @_;
  unless($const) {
    eval { bools::rbo($$ref) };
    is($@, '', "rbo($name)");
  }
  eval { bools::const_rbo($$ref) };
  is($@, '', "const_rbo($name)");
}
sub check_ptr { my($ref, $val, $name, $const) = @_;
  check_val(\ bools::value($$ref), $val, "value($name)", 1);
  unless($const) {
    eval { bools::pbo($$ref) };
    is($@, '', "pbo($name)");
  }
  eval { bools::const_pbo($$ref) };
  is($@, '', "const_pbo($name)");
  check_ref($ref, $val, $name, $const);
}


check_val(\ 1, 1,  '1', 0);
check_val(\ 0, '', '0', 0);
check_val(\ bools::eax(), 1, 'eax()', 0);
check_var(\ $bools::constbool, '', 'constbool', 1);
check_var(\ $bools::bool1, 1,  'bool1', 0);
check_var(\ $bools::bool2, '', 'bool2', 0);
check_ptr(\ $bools::pbool, 1,  'pbool', 0);
check_ref(\ $bools::rbool, '', 'rbool', 0);
check_ptr(\ $bools::const_pbool, 1,  'pbool', 1);
check_ref(\ $bools::const_rbool, '', 'rbool', 1);
check_var(\ $obj->{m_bool1}, 1,  'obj.m_bool1', 0);
check_var(\ $obj->{m_bool2}, '', 'obj.m_bool2', 0);
check_ptr(\ $obj->{m_pbool}, 1,  'obj.m_pbool', 0);
check_ref(\ $obj->{m_rbool}, '', 'obj.m_rbool', 0);
check_ptr(\ $obj->{m_const_pbool}, 1,  'obj.m_const_pbool', 1);
check_ref(\ $obj->{m_const_rbool}, '', 'obj.m_const_rbool', 1);
