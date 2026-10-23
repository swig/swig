use strict;
use warnings;

use Test::More tests => 4;
require_ok('li_cdata_bytes_cpp');
BEGIN { use_ok('li_cdata_bytes_cpp') }

sub test
{
  my $m = li_cdata_bytes_cpp::predefStr();
  my $s = li_cdata_bytes_cpp::cdata($m, 0x200);
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
  my $m2 = li_cdata_bytes_cpp::malloc(0x200);
  li_cdata_bytes_cpp::memmove($m2, $s);
  is(li_cdata_bytes_cpp::verifyBytes($m2), 0, 'verifyBytes');
  li_cdata_bytes_cpp::free($m2);
}
test;
