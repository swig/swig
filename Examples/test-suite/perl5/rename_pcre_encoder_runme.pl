use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('rename_pcre_encoder') }
require_ok('rename_pcre_encoder');

my $s = rename_pcre_encoder::SomeWidget->new();
isa_ok($s, 'rename_pcre_encoder::SomeWidget');
can_ok($s, 'putBorderWidth');
$s->putBorderWidth(3);
can_ok($s, 'getBorderWidth');
is($s->getBorderWidth(), 3);
can_ok($s, 'putSize');
$s->putSize(4, 5);

my $a = rename_pcre_encoder::AnotherWidget->new();
isa_ok($a, 'rename_pcre_encoder::AnotherWidget');
can_ok($a, 'DoSomething');
$a->DoSomething();

my $evt = rename_pcre_encoder::wxEVTSomeEvent->new();
my $t   = rename_pcre_encoder::xUnchangedName->new();
isa_ok($evt, 'rename_pcre_encoder::wxEVTSomeEvent');
isa_ok($t,   'rename_pcre_encoder::xUnchangedName');
