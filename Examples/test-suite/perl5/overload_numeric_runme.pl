use strict;
use warnings;
use Test::More tests => 23;
BEGIN { use_ok('overload_numeric') }
require_ok('overload_numeric');

my $nums = overload_numeric::Nums->new();
my $limits = overload_numeric::Limits->new();

is($nums->over(0), 'signed char');
is($nums->over(0.0), 'float');

is($nums->over($limits->schar_min()), 'signed char');
is($nums->over($limits->schar_max()), 'signed char');

is($nums->over($limits->schar_min() - 1), 'short');
is($nums->over($limits->schar_max() + 1), 'short');
is($nums->over($limits->shrt_min()), 'short');
is($nums->over($limits->shrt_max()), 'short');

is($nums->over($limits->shrt_min() - 1), 'int');
is($nums->over($limits->shrt_max() + 1), 'int');
is($nums->over($limits->int_min()), 'int');
is($nums->over($limits->int_max()), 'int');

is($nums->over($limits->flt_min()), 'float');
is($nums->over($limits->flt_max()), 'float');

is($nums->over($limits->flt_max() * 10), 'double');
is($nums->over(-$limits->flt_max() * 10), 'double');
is($nums->over($limits->dbl_max()), 'double');
is($nums->over(-$limits->dbl_max()), 'double');

is($nums->over('Inf'), 'float');
is($nums->over('-Inf'), 'float');
is($nums->over('NaN'), 'float');

# Just check if the following are accepted without exceptions being thrown
$nums->doublebounce('Inf');
$nums->doublebounce('-Inf');
$nums->doublebounce('NaN');
