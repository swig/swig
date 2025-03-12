use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok 'director_rev_len_str' }
require_ok 'director_rev_len_str';

{
  package DirectorReverseLengthStringCallback;
  use base 'director_rev_len_str::Callback';
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
  my $caller = director_rev_len_str::Caller->new($callback);
  my $sum = $caller->call();

  is($sum, 9*2*8, 'Unexpected sum: ' . $sum);
}
