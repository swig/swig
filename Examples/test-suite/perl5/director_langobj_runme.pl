use strict;
use warnings;
use Test::More tests => 7;
use Scalar::Util qw(refaddr);
use B ();
BEGIN { use_ok 'director_langobj' }
require_ok 'director_langobj';

{
  package MyCallback;
  use base 'director_langobj::Callback';
  our $received;
  sub callback { my($self, $param1) = @_; $received = $param1; }
  sub callback_ref { my($self, $param1) = @_; $received = $param1; }
}

my $handler = MyCallback->new();
my $obj = [1, 2, 3];

# An opaque proxy would arrive as a blessed SWIG object rather than the array
# reference that was passed in.
$MyCallback::received = undef;
director_langobj::call_callback($handler, $obj);
is(ref($MyCallback::received), 'ARRAY', 'callback received an array reference');
is(refaddr($MyCallback::received), refaddr($obj), 'callback received the object itself');

$MyCallback::received = undef;
director_langobj::call_callback_ref($handler, $obj);
is(ref($MyCallback::received), 'ARRAY', 'callback_ref received an array reference');
is(refaddr($MyCallback::received), refaddr($obj), 'callback_ref received the object itself');

# The reference count of the referenced array must not drift as upcalls are made.
$MyCallback::received = undef;
my $before = B::svref_2object($obj)->REFCNT;
for (1 .. 100) {
  director_langobj::call_callback($handler, $obj);
  director_langobj::call_callback_ref($handler, $obj);
}
$MyCallback::received = undef;
my $after = B::svref_2object($obj)->REFCNT;
is($after, $before, 'reference count stable across director upcalls');
