use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('cpp11_move_typemaps') }
require_ok('cpp11_move_typemaps');

{
  cpp11_move_typemaps::Counter::reset_counts();
  my $mo = new cpp11_move_typemaps::MoveOnly(111);
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 0, 0, 0);
  cpp11_move_typemaps::MoveOnly::take($mo);
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
  undef $mo;
}
cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);

{
  cpp11_move_typemaps::Counter::reset_counts();
  my $mo = new cpp11_move_typemaps::MovableCopyable(111);
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 0, 0, 0);
  cpp11_move_typemaps::MovableCopyable::take($mo);
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
  undef $mo;
}
cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);

{
  my $mo = new cpp11_move_typemaps::MoveOnly(222);
  cpp11_move_typemaps::MoveOnly::take($mo);
  eval {
    cpp11_move_typemaps::MoveOnly::take($mo);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "double usage of takeKlassUniquePtr should be an error");
}

{
  cpp11_move_typemaps::Counter::reset_counts();
  my $imt = new cpp11_move_typemaps::InstanceMethodsTester();
  {
    my $mo = new cpp11_move_typemaps::MoveOnly(333);
    cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 0, 0, 0);
    $imt->instance_take_move_only($mo);
    cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
    undef $mo;
  }
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
  cpp11_move_typemaps::Counter::reset_counts();
  {
    my $mc = new cpp11_move_typemaps::MovableCopyable(444);
    cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 0, 0, 0);
    $imt->instance_take_movable_copyable($mc);
    cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
    undef $mc;
  }
  cpp11_move_typemaps::Counter::check_counts(1, 0, 0, 1, 0, 2);
}
