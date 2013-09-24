use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok('smart_pointer_member') }
require_ok('smart_pointer_member');

my $f = smart_pointer_member::Foo->new();
$f->{y} = 1;
is($f->{y}, 1);

my $b = smart_pointer_member::Bar->new($f);
$b->{y} = 2;
is($f->{y}, 2);

is($b->{x}, $f->{x});

is($b->{z}, $f->{z});

isnt($smart_pointer_member::Foo::z, $smart_pointer_member::Bar::z);
