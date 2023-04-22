#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('static_member_overload') }

my $f;

# static member
is(static_member_overload::Foo::sum(1, 2, 3), 6);

# should fail
eval { static_member_overload::Foo::sum(1, 2) };
like($@, qr/No matching function/);

# instance member
$f = static_member_overload::Foo->new();
is($f->sum(1, 2), 3);

# should fail
eval { $f->sum(1, 2, 3) };
like($@, qr/No matching function/);
