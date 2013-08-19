use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok('cpp_namespace') }
require_ok('cpp_namespace');

my $n = cpp_namespace::fact(4);
is($n, 24, "return value");

is($cpp_namespace::Foo, 42, "variable value");

my $t = cpp_namespace::Test->new();
is($t->method(), "Test::method", "method return value");
is(cpp_namespace::do_method($t), "Test::method", "return value");

is(cpp_namespace::do_method2($t), "Test::method", "return value");

cpp_namespace::weird("hello", 4);

undef $t;

my $t2 = cpp_namespace::Test2->new();
my $t3 = cpp_namespace::Test3->new();
my $t4 = cpp_namespace::Test4->new();
my $t5 = cpp_namespace::Test5->new();

is(cpp_namespace::foo3(42), 42, 'return value');
is(cpp_namespace::do_method3($t2, 40), "Test2::method", "return value");
is(cpp_namespace::do_method3($t3, 40), "Test3::method", "return value");
is(cpp_namespace::do_method3($t4, 40), "Test4::method", "return value");
is(cpp_namespace::do_method3($t5, 40), "Test5::method", "return value");
