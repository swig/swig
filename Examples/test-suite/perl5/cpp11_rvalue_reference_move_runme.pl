use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok('cpp11_rvalue_reference_move') }
require_ok('cpp11_rvalue_reference_move');

{
  # Function containing rvalue reference parameter
  cpp11_rvalue_reference_move::Counter::reset_counts();
  my $mo = new cpp11_rvalue_reference_move::MovableCopyable(222);
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 0, 0, 0);
  cpp11_rvalue_reference_move::MovableCopyable::movein($mo);
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 1, 0, 2);
  is(cpp11_rvalue_reference_move::MovableCopyable::is_nullptr($mo), 1, "is_nullptr check");
  undef $mo;
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 1, 0, 2);
}

{
  # Move constructor test
  cpp11_rvalue_reference_move::Counter::reset_counts();
  my $mo = new cpp11_rvalue_reference_move::MovableCopyable(222);
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 0, 0, 0);
  my $mo_moved = new cpp11_rvalue_reference_move::MovableCopyable($mo);
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 1, 0, 1);
  is(cpp11_rvalue_reference_move::MovableCopyable::is_nullptr($mo), 1, "is_nullptr check");
  undef $mo;
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 1, 0, 1);
  undef $mo_moved;
  cpp11_rvalue_reference_move::Counter::check_counts(1, 0, 0, 1, 0, 2);
}

{
  # Move assignment operator test
  cpp11_rvalue_reference_move::Counter::reset_counts();
  my $mo111 = new cpp11_rvalue_reference_move::MovableCopyable(111);
  my $mo222 = new cpp11_rvalue_reference_move::MovableCopyable(222);
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 0, 0);
  $mo111->MoveAssign($mo222);
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 1, 1);
  is(cpp11_rvalue_reference_move::MovableCopyable::is_nullptr($mo222), 1, "is_nullptr check");
  undef $mo222;
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 1, 1);
  undef $mo111;
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 1, 2);
}

{
  # null check
  cpp11_rvalue_reference_move::Counter::reset_counts();
  eval {
    cpp11_rvalue_reference_move::MovableCopyable::movein(undef);
  };
  like($@, qr/\binvalid null reference/, "Should have thrown null error");
  cpp11_rvalue_reference_move::Counter::check_counts(0, 0, 0, 0, 0, 0);
}

{
  # output
  cpp11_rvalue_reference_move::Counter::reset_counts();
  my $mc = cpp11_rvalue_reference_move::MovableCopyable::moveout(1234);
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 1, 1);
  cpp11_rvalue_reference_move::MovableCopyable::check_numbers_match($mc, 1234);

  eval {
    cpp11_rvalue_reference_move::MovableCopyable::movein($mc);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "Should have thrown 'Cannot release ownership as memory is not owned' error");
  cpp11_rvalue_reference_move::Counter::check_counts(2, 0, 0, 0, 1, 1);
}
