use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('template_ns') }
require_ok('template_ns');

my $p1 = template_ns::pairii->new(2, 3);
my $p2 = template_ns::pairii->new($p1);

is($p2->{first}, 2);
is($p2->{second}, 3);

my $p3 = template_ns::pairdd->new(3.5, 2.5);
my $p4 = template_ns::pairdd->new($p3);

is($p4->{first}, 3.5);
is($p4->{second}, 2.5);
