use strict;
use warnings;
use Test::More tests => 34;
BEGIN { use_ok('li_std_auto_ptr') }
require_ok('li_std_auto_ptr');

# adapted from ../java/li_std_auto_ptr_runme.java

sub checkCount {
  my($expected_count) = @_;
  my $actual_count = li_std_auto_ptr::Klass::getTotal_count();
  is($actual_count, $expected_count, "Counts incorrect, expected: $expected_count actual: $actual_count");
}

# Test raw pointer handling involving virtual inheritance
{
  my $kini = new li_std_auto_ptr::KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  my $s = li_std_auto_ptr::useKlassRawPtr($kini);
  is($s, "KlassInheritanceInput", "Incorrect string: $s");
  undef $kini;
  checkCount(0);
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

li_std_auto_ptr::takeKlassAutoPtr(undef);
li_std_auto_ptr::takeKlassAutoPtr(li_std_auto_ptr::make_null());
checkCount(0);

# overloaded parameters
is(li_std_auto_ptr::overloadTest(), 0, "overloadTest failed");
is(li_std_auto_ptr::overloadTest(undef), 1, "overloadTest failed");
is(li_std_auto_ptr::overloadTest(new li_std_auto_ptr::Klass("over")), 1, "overloadTest failed");
checkCount(0);


# auto_ptr as output
my $k1 = li_std_auto_ptr::makeKlassAutoPtr("first");
my $k2 = li_std_auto_ptr::makeKlassAutoPtr("second");
checkCount(2);

undef $k1;
checkCount(1);

is($k2->getLabel, "second", "proper label");

undef $k2;
checkCount(0);

is(li_std_auto_ptr::makeNullAutoPtr(), undef);
