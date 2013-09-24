use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok('array_typedef_memberin') }
require_ok('array_typedef_memberin');

my $obj = array_typedef_memberin::ExampleDetail->new();

$obj->{node_list} = $obj->{node_list2};
$obj->{node_list} = $obj->{node_list3};
$obj->fn1($obj->{node_list});
$obj->fn2($obj->{node_list});
$obj->fn3($obj->{node_list});
