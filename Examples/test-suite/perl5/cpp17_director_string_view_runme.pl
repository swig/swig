use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok 'cpp17_director_string_view' }
require_ok 'cpp17_director_string_view';

{
  package B;
  use base 'cpp17_director_string_view::A';
  our $in_first = 0;
  sub get_first { my($self) = @_;
    die "SUPER RESOLVE BAD" if $in_first;
    local $in_first = 1;
    # Since std::string_view contains a pointer into a string, the string
    # cannot be a temporary in order to avoid undefined behaviour.
    my $x = $self->SUPER::get_first();
    $self->{cached_string} = $x . " world!";
    return $self->{cached_string};
  }
  our $in_process_text = 0;
  sub process_text { my($self, $string) = @_;
    die "SUPER RESOLVE BAD" if $in_process_text;
    local $in_process_text = 1;
    $self->SUPER::process_text($string);
    $self->{'smem'} = "hello";
  }
}

my $b = B->new("hello");
isa_ok $b, 'B';

is $b->get(0), "hello";

{ local $TODO = "Return value gets corrupted";
is $b->get_first(), "hello world!";
is $b->call_get_first(), "hello world!";
}

$b->call_process_func();

is $b->{'smem'}, "hello";
