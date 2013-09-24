use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('rename_strip_encoder') }
require_ok('rename_strip_encoder');

my $s = rename_strip_encoder::SomeWidget->new();
isa_ok($s, 'rename_strip_encoder::SomeWidget');
my $a = rename_strip_encoder::AnotherWidget->new();
isa_ok($a, 'rename_strip_encoder::AnotherWidget');
can_ok($a, 'DoSomething');
$a->DoSomething();
