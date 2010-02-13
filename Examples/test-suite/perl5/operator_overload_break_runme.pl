use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok 'operator_overload_break' }
require_ok 'operator_overload_break';
use constant {
    true => '1',
    false => '',
};

# the .i dumps a pile on stdout we don't need to see when we runtests()
use POSIX;
POSIX::close(2);
# Workaround for 
#   ok( not (expression) , "test description" );
# does not working in older versions of Perl, eg 5.004_04
sub ok_not ($;$) {
    my($test, $name) = @_;
    $test = not $test;
    ok($test, $name);
}

my $op = operator_overload_break::Op->new(5);

isa_ok($op, "operator_overload_break::Op");

is($op - 3 == 2, true, 'subtraction');

$op->{k} = 37;

is($op + 3 == 40, true, "addition");

$op->{k} = 22;

is(32 - $op == 10, true, "reversed subtraction");

is($op == 3, false, 'not equal');

$op->{k} = 3;

++$op;
is($op == 4, true, "pre-increment operator");

$op++;
is($op == 5, true, "post-increment operator");

my $op2 = ++$op;
$op2 = $op++;

is $op2 == 6, true, "multiple post-increments";
is $op == 7, true, "multiple post-increments";
