use strict;
use warnings;
use Test::More tests => 25;
BEGIN { use_ok('li_std_auto_ptr') }
require_ok('li_std_auto_ptr');

# adapted from ../java/li_std_auto_ptr_runme.java

sub checkCount {
  my($expected_count) = @_;
  my $actual_count = li_std_auto_ptr::Klass::getTotal_count();
  is($actual_count, $expected_count, "Counts incorrect, expected: $expected_count actual: $actual_count");
}

# auto_ptr as input
{
  my $kin = new li_std_auto_ptr::Klass("KlassInput");
  checkCount(1);
  my $s = li_std_auto_ptr::takeKlassAutoPtr($kin);
  checkCount(0);
  is($s, "KlassInput", "Incorrect string: $s");
  is(li_std_auto_ptr::is_nullptr($kin), 1, "is_nullptr check");
  undef $kin; # Should not fail, even though already deleted
  checkCount(0);
}

{
  my $kin = new li_std_auto_ptr::Klass("KlassInput");
  checkCount(1);
  my $s = li_std_auto_ptr::takeKlassAutoPtr($kin);
  checkCount(0);
  is($s, "KlassInput", "Incorrect string: $s");
  is(li_std_auto_ptr::is_nullptr($kin), 1, "is_nullptr check");
  eval {
    li_std_auto_ptr::takeKlassAutoPtr($kin);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "double usage of takeKlassAutoPtr should be an error");
  undef $kin; # Should not fail, even though already deleted
  checkCount(0);
}

{
  my $kin = new li_std_auto_ptr::Klass("KlassInput");
  my $notowned = li_std_auto_ptr::get_not_owned_ptr($kin);
  eval {
    li_std_auto_ptr::takeKlassAutoPtr($notowned);
  };
  like($@, qr/\bcannot release ownership as memory is not owned\b/, "double usage of takeKlassAutoPtr should be an error");
  checkCount(1);
  undef $kin;
  checkCount(0);
}

{
  my $kini = new li_std_auto_ptr::KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  my $s = li_std_auto_ptr::takeKlassAutoPtr($kini);
  checkCount(0);
  is($s, "KlassInheritanceInput", "Incorrect string: $s");
  is(li_std_auto_ptr::is_nullptr($kini), 1, "is_nullptr failed");
  undef $kini; # Should not fail, even though already deleted
  checkCount(0);
}

# auto_ptr as output
my $k1 = li_std_auto_ptr::makeKlassAutoPtr("first");
my $k2 = li_std_auto_ptr::makeKlassAutoPtr("second");
is(li_std_auto_ptr::Klass::getTotal_count, 2, "have 2 pointers");

undef $k1;
is(li_std_auto_ptr::Klass::getTotal_count, 1, "left 1 pointer");

is($k2->getLabel, "second", "proper label");

undef $k2;
is(li_std_auto_ptr::Klass::getTotal_count, 0, "remove all pointers");
