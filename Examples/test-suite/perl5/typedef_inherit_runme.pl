use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('typedef_inherit') }
require_ok('typedef_inherit');

my $a = typedef_inherit::Foo->new();
my $b = typedef_inherit::Bar->new();

my $x = typedef_inherit::do_blah($a);
is($x, "Foo::blah", "Whoa! Bad return");

$x = typedef_inherit::do_blah($b);
is($x, "Bar::blah", "Whoa! Bad return");

my $c = typedef_inherit::Spam->new();
my $d = typedef_inherit::Grok->new();

$x = typedef_inherit::do_blah2($c);
is($x, "Spam::blah", "Whoa! Bad return");

$x = typedef_inherit::do_blah2($d);
is($x, "Grok::blah", "Whoa! Bad return");
