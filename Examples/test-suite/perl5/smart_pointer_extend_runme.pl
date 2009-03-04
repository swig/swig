use strict;
use warnings;
use Test::More tests => 15;
BEGIN { use_ok 'smart_pointer_extend' }
require_ok 'smart_pointer_extend';

my $f = smart_pointer_extend::Foo->new();
isa_ok($f, 'smart_pointer_extend::Foo');
my $b = smart_pointer_extend::Bar->new($f);
isa_ok($b, 'smart_pointer_extend::Bar');

is($f->extension(), $b->extension());

$b = smart_pointer_extend::CBase->new();
isa_ok($b, 'smart_pointer_extend::CBase');
my $d = smart_pointer_extend::CDerived->new();
isa_ok($d, 'smart_pointer_extend::CDerived');
my $p = smart_pointer_extend::CPtr->new();
isa_ok($p, 'smart_pointer_extend::CPtr');

is($b->bar(), $p->bar());
is($d->foo(), $p->foo());
is($b->can('hello')->(), $p->hello());

$d = smart_pointer_extend::DFoo->new();
isa_ok($d, 'smart_pointer_extend::DFoo');
my $dp = smart_pointer_extend::DPtrFoo->new($d);
isa_ok($dp, 'smart_pointer_extend::DPtrFoo');

is($d->can('SExt')->(1), $dp->SExt(1));
is($d->Ext(1), $dp->Ext(1));
