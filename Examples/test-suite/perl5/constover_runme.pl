use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok('constover') }
require_ok('constover');

is(constover::test("test"), "test", "test");
is(constover::test_pconst("test"), "test_pconst", "test_pconst");

my $f = constover::Foo->new();
is($f->test("test"), "test", "member-test");
is($f->test_pconst("test"), "test_pconst", "member-test_pconst");

is($f->test_constm("test"), "test_constmethod", "member-test_constm");
is($f->test_pconstm("test"), "test_pconstmethod", "member-test_pconstm");
