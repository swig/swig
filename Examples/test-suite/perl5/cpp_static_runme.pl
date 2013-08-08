use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('cpp_static') }
require_ok('cpp_static');

can_ok('cpp_static::StaticFunctionTest', 'static_func');
cpp_static::StaticFunctionTest->static_func();
can_ok('cpp_static::StaticFunctionTest', 'static_func_2');
cpp_static::StaticFunctionTest->static_func_2(1);
can_ok('cpp_static::StaticFunctionTest', 'static_func_3');
cpp_static::StaticFunctionTest->static_func_3(1, 2);
$cpp_static::StaticMemberTest::static_int = 10;
is($cpp_static::StaticMemberTest::static_int, 10);
