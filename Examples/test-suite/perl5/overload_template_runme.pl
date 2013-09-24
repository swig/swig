use strict;
use warnings;
use Test::More tests => 46;
BEGIN { use_ok('overload_template') }
require_ok('overload_template');

my $f = overload_template::foo();

my $a = overload_template::maximum(3, 4);
my $b = overload_template::maximum(3.4, 5.2);

# mix 1
is(overload_template::mix1('hi'), 101, 'mix1(const char *)');
is(overload_template::mix1(1.0, 1.0), 102, 'mix1(double, const double &)');
is(overload_template::mix1(1.0), 103, 'mix1(double)');

# mix 2
is(overload_template::mix2('hi'), 101, 'mix2(const char *)');
is(overload_template::mix2(1.0, 1.0), 102, 'mix2(double, const double &)');
is(overload_template::mix2(1.0), 103, 'mix2(double)');

# mix 3
is(overload_template::mix3('hi'), 101, 'mix3(const char *)');
is(overload_template::mix3(1.0, 1.0), 102, 'mix3(double, const double &)');
is(overload_template::mix3(1.0), 103, 'mix3(double)');

# Combination 1
is(overload_template::overtparams1(100), 10, 'overtparams1(int)');
is(overload_template::overtparams1(100.0, 100), 20, 'overtparams1(double, int)');

# Combination 2
is(overload_template::overtparams2(100.0, 100), 40, 'overtparams2(double, int)');

# Combination 3
is(overload_template::overloaded(), 60, 'overloaded()');
is(overload_template::overloaded(100.0, 100), 70, 'overloaded(double, int)');

# Combination 4
is(overload_template::overloadedagain('hello'), 80, 'overloadedagain(const char *)');
is(overload_template::overloadedagain(), 90, 'overloadedagain(double)');

# specializations
is(overload_template::specialization(10), 202, 'specialization(int)');
is(overload_template::specialization(10.0), 203, 'specialization(double)');
is(overload_template::specialization(10, 10), 204, 'specialization(int, int)');
is(overload_template::specialization(10.0, 10.0), 205, 'specialization(double, double)');
is(overload_template::specialization('hi', 'hi'), 201, 'specialization(const char *, const char *)');

# simple specialization
can_ok('overload_template', 'xyz');
can_ok('overload_template', 'xyz_int');
can_ok('overload_template', 'xyz_double');
overload_template::xyz();
overload_template::xyz_int();
overload_template::xyz_double();

# a bit of everything
is(overload_template::overload('hi'), 0, 'overload()');
is(overload_template::overload(1), 10, 'overload(int t)');
is(overload_template::overload(1, 1), 20, 'overload(int t, const int &)');
is(overload_template::overload(1, 'hello'), 30, 'overload(int t, const char *)');

my $k = overload_template::Klass->new();
is(overload_template::overload($k), 10, 'overload(Klass t)');
is(overload_template::overload($k, $k), 20, 'overload(Klass t, const Klass &)');
is(overload_template::overload($k, 'hello'), 30, 'overload(Klass t, const char *)');
is(overload_template::overload(10.0, 'hi'), 40, 'overload(double t, const char *)');
is(overload_template::overload(), 50, 'overload(const char *)');

# everything put in a namespace
is(overload_template::nsoverload('hi'), 1000, 'nsoverload()');
is(overload_template::nsoverload(1), 1010, 'nsoverload(int t)');
is(overload_template::nsoverload(1, 1), 1020, 'nsoverload(int t, const int &)');
is(overload_template::nsoverload(1, 'hello'), 1030, 'nsoverload(int t, const char *)');
is(overload_template::nsoverload($k), 1010, 'nsoverload(Klass t)');
is(overload_template::nsoverload($k, $k), 1020, 'nsoverload(Klass t, const Klass &)');
is(overload_template::nsoverload($k, 'hello'), 1030, 'nsoverload(Klass t, const char *)');
is(overload_template::nsoverload(10.0, 'hi'), 1040, 'nsoverload(double t, const char *)');
is(overload_template::nsoverload(), 1050, 'nsoverload(const char *)');

can_ok('overload_template::A', 'foo');
overload_template::A->foo(1);
can_ok('overload_template::B', 'foo');
overload_template::B->new()->foo(1);
