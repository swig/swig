use strict;
use warnings;
use Test::More tests => 17;
BEGIN { use_ok('template_inherit') }
require_ok('template_inherit');

my $a = template_inherit::FooInt->new();
my $b = template_inherit::FooDouble->new();
my $c = template_inherit::BarInt->new();
my $d = template_inherit::BarDouble->new();
my $e = template_inherit::FooUInt->new();
my $f = template_inherit::BarUInt->new();

is($a->blah(), 'Foo');
is($b->blah(), 'Foo');
is($e->blah(), 'Foo');
is($c->blah(), 'Bar');
is($d->blah(), 'Bar');
is($f->blah(), 'Bar');
is($c->foomethod(), 'foomethod');
is($d->foomethod(), 'foomethod');
is($f->foomethod(), 'foomethod');
is(template_inherit::invoke_blah_int($a), 'Foo');
is(template_inherit::invoke_blah_int($c), 'Bar');
is(template_inherit::invoke_blah_double($b), 'Foo');
is(template_inherit::invoke_blah_double($d), 'Bar');
is(template_inherit::invoke_blah_uint($e), 'Foo');
is(template_inherit::invoke_blah_uint($f), 'Bar');
