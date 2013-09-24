use strict;
use warnings;
use Test::More tests => 24;
BEGIN {
  use_ok('mod_a');
  use_ok('mod_b');
}
require_ok('mod_a');
require_ok('mod_b');

my @l = (
  mod_a::A->new(),
  mod_a::B->new(),
  mod_b::C->new(),
  mod_b::D->new(),
);

for my $x (@l) {
  can_ok($x, 'GetC');
  $x->GetC();
  for my $y (@l) {
    $x->DoSomething($y);
    ok(1, "${\ ref($x) }->DoSomething(${\ ref $y })");
  }
}
