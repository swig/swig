#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 27;
BEGIN { use_ok('li_constraints') }
require_ok('li_constraints');

sub check_double {
    my ($except, $func, $name, $val) = @_;
    my $fname = "li_constraints::test_$name";
    $fname =~ s/-//;
    my $actual = eval { $func->($val); 1; };
    my $err = $@;
    $actual = 0 unless defined $actual;
    if($actual) {
      is($actual, $except, "$fname pass with $val");
    } else {
      is($actual, $except, "$fname throw exception with $val");
      ok($err =~ "^ValueError Expected a $name value.", "$fname throw proper exception");
    }
}

my $nonnegative = sub { li_constraints::test_nonnegative(shift); };
check_double(1, $nonnegative, "non-negative", 10);
check_double(1, $nonnegative, "non-negative", 0);
check_double(0, $nonnegative, "non-negative", -10);

my $nonpositive = sub { li_constraints::test_nonpositive(shift); };
check_double(0, $nonpositive, "non-positive", 10);
check_double(1, $nonpositive, "non-positive", 0);
check_double(1, $nonpositive, "non-positive", -10);

my $positive = sub { li_constraints::test_positive(shift); };
check_double(1, $positive, "positive", 10);
check_double(0, $positive, "positive", 0);
check_double(0, $positive, "positive", -10);

my $negative = sub { li_constraints::test_negative(shift); };
check_double(0, $negative, "negative", 10);
check_double(0, $negative, "negative", 0);
check_double(1, $negative, "negative", -10);

my $nonzero = sub { li_constraints::test_nonzero(shift); };
check_double(1, $nonzero, "nonzero", 10);
check_double(0, $nonzero, "nonzero", 0);
check_double(1, $nonzero, "nonzero", -10);

# Pass null value
my $ret = eval { li_constraints::test_nonnull(undef); 1; };
my $err = $@;
is($ret, undef, "li_constraints::test_nonnull throw exception with null");
ok($err =~ "^NullReferenceError Received a NULL pointer.", "li_constraints::test_nonnull throw proper exception");
my $ptr = li_constraints::get_nonnull();
# There should be no exception, we can use Perl lambda function
$ret = (sub { li_constraints::test_nonnull($ptr); 1; })->();
is($ret, 1, "li_constraints::test_nonnull pass with non null value");
