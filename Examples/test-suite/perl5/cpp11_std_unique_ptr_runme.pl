use strict;
use warnings;
use Test::More tests => 25;
BEGIN { use_ok('cpp11_std_unique_ptr') }
require_ok('cpp11_std_unique_ptr');

# adapted from ../java/cpp11_std_unique_ptr_runme.java

sub checkCount {
  my($expected_count) = @_;
  my $actual_count = cpp11_std_unique_ptr::Klass::getTotal_count();
  is($actual_count, $expected_count, "Counts incorrect, expected: $expected_count actual: $actual_count");
}

# unique_ptr as input
{
  my $kin = new cpp11_std_unique_ptr::Klass("KlassInput");
  checkCount(1);
  my $s = cpp11_std_unique_ptr::takeKlassUniquePtr($kin);
  checkCount(0);
  is($s, "KlassInput", "Incorrect string: $s");
  is(cpp11_std_unique_ptr::is_nullptr($kin), 1, "is_nullptr check");
  undef $kin; # Should not fail, even though already deleted
  checkCount(0);
}

{
  my $kin = new cpp11_std_unique_ptr::Klass("KlassInput");
  checkCount(1);
  my $s = cpp11_std_unique_ptr::takeKlassUniquePtr($kin);
  checkCount(0);
  is($s, "KlassInput", "Incorrect string: $s");
  is(cpp11_std_unique_ptr::is_nullptr($kin), 1, "is_nullptr check");
  eval {
    cpp11_std_unique_ptr::takeKlassUniquePtr($kin);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "double usage of takeKlassUniquePtr should be an error");
  undef $kin; # Should not fail, even though already deleted
  checkCount(0);
}

{
  my $kin = new cpp11_std_unique_ptr::Klass("KlassInput");
  my $notowned = cpp11_std_unique_ptr::get_not_owned_ptr($kin);
  eval {
    cpp11_std_unique_ptr::takeKlassUniquePtr($notowned);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "double usage of takeKlassUniquePtr should be an error");
  checkCount(1);
  undef $kin;
  checkCount(0);
}

{
  my $kini = new cpp11_std_unique_ptr::KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  my $s = cpp11_std_unique_ptr::takeKlassUniquePtr($kini);
  checkCount(0);
  is($s, "KlassInheritanceInput", "Incorrect string: $s");
  is(cpp11_std_unique_ptr::is_nullptr($kini), 1, "is_nullptr failed");
  undef $kini; # Should not fail, even though already deleted
  checkCount(0);
}

# unique_ptr as output
my $k1 = cpp11_std_unique_ptr::makeKlassUniquePtr("first");
my $k2 = cpp11_std_unique_ptr::makeKlassUniquePtr("second");
is(cpp11_std_unique_ptr::Klass::getTotal_count, 2, "have 2 pointers");

undef $k1;
is(cpp11_std_unique_ptr::Klass::getTotal_count, 1, "left 1 pointer");

is($k2->getLabel, "second", "proper label");

undef $k2;
is(cpp11_std_unique_ptr::Klass::getTotal_count, 0, "remove all pointers");
