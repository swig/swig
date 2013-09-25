use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('memberin_extend') }
require_ok('memberin_extend');


my $em1 = memberin_extend::ExtendMe->new();
my $em2 = memberin_extend::ExtendMe->new();
$em1->{thing} = 'em1thing';
$em2->{thing} = 'em2thing';
is($em1->{thing}, 'em1thing', 'em1thing');
is($em2->{thing}, 'em2thing', 'em2thing');
