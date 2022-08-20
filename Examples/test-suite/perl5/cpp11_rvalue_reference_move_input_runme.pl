use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('cpp11_rvalue_reference_move_input') }
require_ok('cpp11_rvalue_reference_move_input');

{
  # Function containing rvalue reference parameter
  cpp11_rvalue_reference_move_input::Counter::reset_counts();
  my $mo = new cpp11_rvalue_reference_move_input::MovableCopyable(222);
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 0, 0, 0);
  cpp11_rvalue_reference_move_input::MovableCopyable::movein($mo);
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 1, 0, 2);
  is(cpp11_rvalue_reference_move_input::MovableCopyable::is_nullptr($mo), 1, "is_nullptr check");
  undef $mo;
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 1, 0, 2);
}

{
  # Move constructor test
  cpp11_rvalue_reference_move_input::Counter::reset_counts();
  my $mo = new cpp11_rvalue_reference_move_input::MovableCopyable(222);
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 0, 0, 0);
  my $mo_moved = new cpp11_rvalue_reference_move_input::MovableCopyable($mo);
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 1, 0, 1);
  is(cpp11_rvalue_reference_move_input::MovableCopyable::is_nullptr($mo), 1, "is_nullptr check");
  undef $mo;
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 1, 0, 1);
  undef $mo_moved;
  cpp11_rvalue_reference_move_input::Counter::check_counts(1, 0, 0, 1, 0, 2);
}

{
  # Move assignment operator test
  cpp11_rvalue_reference_move_input::Counter::reset_counts();
  my $mo111 = new cpp11_rvalue_reference_move_input::MovableCopyable(111);
  my $mo222 = new cpp11_rvalue_reference_move_input::MovableCopyable(222);
  cpp11_rvalue_reference_move_input::Counter::check_counts(2, 0, 0, 0, 0, 0);
  $mo111->MoveAssign($mo222);
  cpp11_rvalue_reference_move_input::Counter::check_counts(2, 0, 0, 0, 1, 1);
  is(cpp11_rvalue_reference_move_input::MovableCopyable::is_nullptr($mo222), 1, "is_nullptr check");
  undef $mo222;
  cpp11_rvalue_reference_move_input::Counter::check_counts(2, 0, 0, 0, 1, 1);
  undef $mo111;
  cpp11_rvalue_reference_move_input::Counter::check_counts(2, 0, 0, 0, 1, 2);
}

{
  # null check
  cpp11_rvalue_reference_move_input::Counter::reset_counts();
  eval {
    cpp11_rvalue_reference_move_input::MovableCopyable::movein(undef);
  };
  like($@, qr/\binvalid null reference/, "Should have thrown null error");
  cpp11_rvalue_reference_move_input::Counter::check_counts(0, 0, 0, 0, 0, 0);
}
