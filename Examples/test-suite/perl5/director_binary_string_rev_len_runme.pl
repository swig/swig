use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok 'director_binary_string_rev_len' }
require_ok 'director_binary_string_rev_len';

{
  package DirectorReverseLengthStringCallback;
  use base 'director_binary_string_rev_len::Callback';
  sub run {
      my $ret = 0;
      my ($self, $dataBufferAA) = @_;
      if(defined $dataBufferAA) {
        $ret += ord($_) * 2 for(split('', $dataBufferAA));
      }
      return $ret;
  }
}

{
  print "Start\n";
  my $callback = DirectorReverseLengthStringCallback->new();
  my $caller = director_binary_string_rev_len::Caller->new($callback);
  my $sum = $caller->call();

  is($sum, 9*2*8, 'Unexpected sum: ' . $sum);
}
