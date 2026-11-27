director_member_pointer

function self=MyMemberPtrDirector()
  global director_member_pointer;
  self=subclass(director_member_pointer.MemberPtrDirector());
  self.useMemberPtr=@MyMemberPtrDirector_useMemberPtr;
  self.useMemberPtrCref=@MyMemberPtrDirector_useMemberPtrCref;
  self.getMemberPtr=@MyMemberPtrDirector_getMemberPtr;
  self.getMemberPtrCref=@MyMemberPtrDirector_getMemberPtrCref;
end
function ret=MyMemberPtrDirector_useMemberPtr(self, m, x)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_callMemberPtr(m, x + 10);
end
function ret=MyMemberPtrDirector_useMemberPtrCref(self, m, x)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_callMemberPtr(m, x + 20);
end
function ret=MyMemberPtrDirector_getMemberPtr(self)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_addPtr();
end
function ret=MyMemberPtrDirector_getMemberPtrCref(self)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_addPtr();
end

d = MemberPtrDirector();
if (d.callUseMemberPtr(5) != 7)
  error("Base useMemberPtr");
end
if (d.callUseMemberPtrCref(5) != 7)
  error("Base useMemberPtrCref");
end
if (d.callGetMemberPtr(5) != 6)
  error("Base getMemberPtr");
end
if (d.callGetMemberPtrCref(5) != 6)
  error("Base getMemberPtrCref");
end
d = MyMemberPtrDirector();
if (d.callUseMemberPtr(5) != 17)
  error("Director useMemberPtr");
end
if (d.callUseMemberPtrCref(5) != 27)
  error("Director useMemberPtrCref");
end
if (d.callGetMemberPtr(5) != 7)
  error("Director getMemberPtr");
end
if (d.callGetMemberPtrCref(5) != 7)
  error("Director getMemberPtrCref");
end
