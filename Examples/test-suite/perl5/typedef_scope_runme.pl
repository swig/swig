use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('typedef_scope') }
require_ok('typedef_scope');

my $b = typedef_scope::Bar->new();
my $x = $b->test1(42, "hello");
is($x, 42, "Failed!!");
$x = $b->test2(42, "hello");
is($x, "hello", "Failed!!");
    
    
