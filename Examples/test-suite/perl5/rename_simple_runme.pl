use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('rename_simple') }
require_ok 'rename_simple';

my $s = rename_simple::NewStruct->new();
is($s->{NewInstanceVariable}, 111, 'NewInstanceVariable');
is($s->NewInstanceMethod, 222, 'NewInstanceMethod');
is(rename_simple::NewStruct::NewStaticMethod(), 333, 'NewStaticMethod');
is($rename_simple::NewStruct::NewStaticVariable, 444, 'NewStaticVariable');
is(rename_simple::NewFunction(), 555, 'NewFunction');
is($rename_simple::NewGlobalVariable, 666, 'NewGlobalVariable');

$s->{NewInstanceVariable} = 1111;
$rename_simple::NewStruct::NewStaticVariable = 4444;
$rename_simple::NewGlobalVariable = 6666;

is($s->{NewInstanceVariable}, 1111, 'NewInstanceVariable');
is($rename_simple::NewStruct::NewStaticVariable, 4444, 'NewStaticVariable');
is($rename_simple::NewGlobalVariable, 6666, 'NewGlobalVariable');
