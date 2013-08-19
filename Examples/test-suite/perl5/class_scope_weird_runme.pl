use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok('class_scope_weird') }
require_ok('class_scope_weird');


my $f = class_scope_weird::Foo->new();
isa_ok($f, 'class_scope_weird::Foo');
my $g = class_scope_weird::Foo->new(3);
isa_ok($g, 'class_scope_weird::Foo');
is($f->bar(33), 33);

my $h = class_scope_weird::Quat->new();
isa_ok($h, 'class_scope_weird::Quat');
my $i = class_scope_weird::Quat->new(1.2, 3.4, 5.6, 7.8);
isa_ok($i, 'class_scope_weird::Quat');
