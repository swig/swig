<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('MemberPtrDirector'));
// No new vars
check::globals(array());

class MyMemberPtrDirector extends MemberPtrDirector {
  function useMemberPtr($m, $x) {
    return MemberPtrDirector::callMemberPtr($m, $x + 10);
  }
  function getMemberPtr() {
    return MemberPtrDirector::addPtr();
  }
}

$d = new MemberPtrDirector();
check::equal($d->callUseMemberPtr(5), 7, "Base useMemberPtr");
check::equal($d->callGetMemberPtr(5), 6, "Base getMemberPtr");
$d = new MyMemberPtrDirector();
check::equal($d->callUseMemberPtr(5), 17, "Director useMemberPtr");
check::equal($d->callGetMemberPtr(5), 7, "Director getMemberPtr");

check::done();
