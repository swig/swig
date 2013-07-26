use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok 'template_ref_type' }
require_ok 'template_ref_type';


my $xr = template_ref_type::XC->new();
isa_ok($xr, 'template_ref_type::XC');
my $y = template_ref_type::Y->new();
isa_ok($y, 'template_ref_type::Y');

is($y->find($xr), '', 'template ref');
