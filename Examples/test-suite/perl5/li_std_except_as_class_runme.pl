use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('li_std_except_as_class') }
require_ok('li_std_except_as_class');

# std::domain_error hierarchy
eval { li_std_except_as_class::test_domain_error() };
isa_ok($@, 'li_std_except_as_class::domain_error');

eval { li_std_except_as_class::test_domain_error() };
isa_ok($@, 'li_std_except_as_class::logic_error');

eval { li_std_except_as_class::test_domain_error() };
isa_ok($@, 'li_std_except_as_class::exception');
