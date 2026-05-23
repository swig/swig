use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok 'director_minimal' }
require_ok 'director_minimal';

{
  package MyMinimal;
  use base 'director_minimal::Minimal';
  sub run { 1; }
}

my $c = MyMinimal->new();
isa_ok $c, 'MyMinimal';
is $c->get(), 1, 'return true';
