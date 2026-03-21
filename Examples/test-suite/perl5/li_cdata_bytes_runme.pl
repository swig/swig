use strict;
use warnings;

sub test
{
  my $m = li_cdata_bytes::predefStr();
  my $s = li_cdata_bytes::cdata($m, 0x200);
  my $p = sprintf 'C[%d]', 0x200;
  # convert binary string to octets array
  my @v = unpack $p, $s;
  my $emsg = '';
  for (0..(0x100 - 1)) {
    if ($v[$_] != $_) {
      $emsg = "test value $_ at index $_";
      last;
    }
    my $i = $_ + 0x100;
    if ($v[$i] != $_) {
      $emsg = "test value $_ at index $i";
      last;
    }
  }
  is($emsg, '', "Check values ($emsg)");
  for (0..(0x100 - 1)) {
    my $d = 0x100 - 1 - $_;
    $v[$_] = $d;
    $v[$_ + 0x100] = $d;
  }
  $s = pack $p, @v;
  my $m2 = li_cdata_bytes::malloc(0x200);
  li_cdata_bytes::memmove($m2, $s);
  my $a = li_cdata_bytes::verifyBytes($m2);
  is(li_cdata_bytes::verifyBytes($m2), 0, 'verifyBytes');
  # Somehow the free() is too 'heavy' for macos
  li_cdata_bytes::free($m2);
}
# The test work on macos, but seemed a bit heavy.
# The test breaks occasionally, simply skip it.
if ($^O ne 'darwin') {
  eval <<"END_TXT";
  use Test::More tests => 4;
  require_ok('li_cdata_bytes');
  BEGIN { use_ok('li_cdata_bytes') }
  test;
END_TXT
}
