use strict;
use warnings;
use Test::More tests => 15;
BEGIN { use_ok('member_funcptr_galore') }
require_ok('member_funcptr_galore');

my $m = member_funcptr_galore::MemberFuncPtrs->new();
is($m->aaa1($member_funcptr_galore::cc1), 0, "aaa1");
is($m->aaa6($member_funcptr_galore::cc6), 0, "aaa6");
is($m->aaa7($member_funcptr_galore::cc7), 0, "aaa7");
is($m->bbb1($member_funcptr_galore::pp1), 0, "bbb1");
is($m->bbb6($member_funcptr_galore::pp6), 0, "bbb6");
is($m->bbb7($member_funcptr_galore::pp7), 0, "bbb7");
is(member_funcptr_galore::call1($member_funcptr_galore::ADD_BY_VALUE, 1, 2), 3, "call1");

# A const reference to a member pointer is passed and returned as the member pointer
is($m->aaa7($member_funcptr_galore::cc1), 0, "aaa7 with cc1");
is($m->aaa1($member_funcptr_galore::cc7), 0, "aaa1 with cc7");

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
eval { $m->aaa1($member_funcptr_galore::pp1) };
like($@, qr/\bTypeError\b/, "aaa1 with pp1");
eval { $m->aaa7($member_funcptr_galore::pp7) };
like($@, qr/\bTypeError\b/, "aaa7 with pp7");
eval { $m->bbb1($member_funcptr_galore::cc1) };
like($@, qr/\bTypeError\b/, "bbb1 with cc1");
eval { $m->bbb7($member_funcptr_galore::cc7) };
like($@, qr/\bTypeError\b/, "bbb7 with cc7");
