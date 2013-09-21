use strict;
use warnings;
use Test::More tests => 16;
BEGIN {
  use_ok('template_typedef_cplx2');
  use_ok('template_typedef_import');
}
require_ok('template_typedef_cplx2');
require_ok('template_typedef_import');

my $s = template_typedef_import::Sin->new();
is($s->get_base_value(), 0);
is($s->get_value(), 1);
is($s->get_arith_value(), 2);
is(template_typedef_import::my_func_r($s), 0);
can_ok(template_typedef_cplx2::make_Multiplies_double_double_double_double($s, $s), 'get_arith_value');

my $z = template_typedef_import::CSin->new();
is($z->get_base_value(), 0);
is($z->get_value(), 1);
is($z->get_arith_value(), 2);
is(template_typedef_import::my_func_c($z), 1);
can_ok(template_typedef_cplx2::make_Multiplies_complex_complex_complex_complex($z, $z), 'get_arith_value');

my $d = template_typedef_cplx2::make_Identity_double();
is(template_typedef_import::my_func_r($d), 0);

my $c = template_typedef_cplx2::make_Identity_complex();
is(template_typedef_import::my_func_c($c), 1);
