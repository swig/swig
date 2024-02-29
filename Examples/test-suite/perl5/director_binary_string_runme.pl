use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok 'director_binary_string' }
require_ok 'director_binary_string';

{
  package DirectorBinaryStringCallback;
  use base 'director_binary_string::Callback';
  sub run {
      my $ret = 0;
      my ($self, $dataBufferAA, $dataBufferBB) = @_;
      if(defined $dataBufferAA) {
        $ret += ord($_) * 2 for(split('', $dataBufferAA));
      }
      if(defined $dataBufferBB) {
        $ret += ord($_) * 3 for(split('', $dataBufferBB));
      }
      return $ret;
  }
  sub writeData {
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
  my $caller = director_binary_string::Caller->new();
  my $callback = DirectorBinaryStringCallback->new();
  $caller->setCallback($callback);
  my $sum = $caller->call();
  my $sumData = $caller->callWriteData();
  $caller->delCallback();

  is($sum, 9*2*8 + 13*3*5, 'Unexpected sum: ' . $sum);
  is($sumData, 9*2*8, 'Unexpected sumData: ' . $sumData);

# FIXME accessing abstract class or protected constructor
# It does make sense as writeData() is abstract
# director_binary_string::Callback->new()->run(undef, undef);
  $callback = DirectorBinaryStringCallback->new();
  $caller->setCallback($callback);
  $caller->call_null();
  $caller->delCallback();
}
