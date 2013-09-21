use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok('threads_exception') }
require_ok('threads_exception');

my $t = threads_exception::Test->new();
eval { $t->unknown() };
isnt($@, undef, 'throw struct');

eval { $t->simple() };
like($@, qr/\b37\b/, 'throw int');

eval { $t->message() };
like($@, qr/\QI died.\E/, 'throw const char *');

eval { $t->hosed() };
isa_ok($@, 'threads_exception::Exc');
is($@->{code}, 42, '.code');
is($@->{msg}, 'Hosed', '.msg');

for(1 .. 4) {
  eval { $t->multi($_) };
  isnt($@, undef, "multi $_");
}
