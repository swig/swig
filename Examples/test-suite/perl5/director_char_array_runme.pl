use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok 'director_char_array' }
require_ok 'director_char_array';

{
  package Director;
  use base 'director_char_array::CharArrayDirector';
  sub take_array { my ($self, $s) = @_; return length($s); }
  sub take_const_array { my ($self, $s) = @_; return length($s); }
  sub take_array_ref { my ($self, $s) = @_; return length($s); }
  sub take_const_array_ref { my ($self, $s) = @_; return length($s); }
  sub is_null_array { my ($self, $s) = @_; return defined($s) ? 0 : 1; }
}

my $d = Director->new();
is($d->call_take_array(), 4, 'take_array');
is($d->call_take_const_array(), 4, 'take_const_array');
is($d->call_take_array_ref(), 4, 'take_array_ref');
is($d->call_take_const_array_ref(), 4, 'take_const_array_ref');
is($d->call_take_array_short(), 2, 'take_array short');
is($d->call_take_array_ref_short(), 2, 'take_array_ref short');
is($d->call_is_null_array(), 1, 'is_null_array');
