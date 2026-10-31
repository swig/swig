use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok 'director_member_pointer' }
require_ok 'director_member_pointer';

{
  package MyMemberPtrDirector;
  use base 'director_member_pointer::MemberPtrDirector';
  sub useMemberPtr {
    my($self, $m, $x) = @_;
    return director_member_pointer::MemberPtrDirector::callMemberPtr($m, $x + 10);
  }
  sub getMemberPtr {
    return director_member_pointer::MemberPtrDirector::addPtr();
  }
}

my $d = director_member_pointer::MemberPtrDirector->new();
is($d->callUseMemberPtr(5), 7, 'Base useMemberPtr');
is($d->callGetMemberPtr(5), 6, 'Base getMemberPtr');
$d = MyMemberPtrDirector->new();
is($d->callUseMemberPtr(5), 17, 'Director useMemberPtr');
is($d->callGetMemberPtr(5), 7, 'Director getMemberPtr');
