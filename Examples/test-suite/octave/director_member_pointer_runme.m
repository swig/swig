director_member_pointer

function self=MyMemberPtrDirector()
  global director_member_pointer;
  self=subclass(director_member_pointer.MemberPtrDirector());
  self.useMemberPtr=@MyMemberPtrDirector_useMemberPtr;
  self.getMemberPtr=@MyMemberPtrDirector_getMemberPtr;
end
function ret=MyMemberPtrDirector_useMemberPtr(self, m, x)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_callMemberPtr(m, x + 10);
end
function ret=MyMemberPtrDirector_getMemberPtr(self)
  global director_member_pointer;
  ret=director_member_pointer.MemberPtrDirector_addPtr();
end

d = MemberPtrDirector();
if (d.callUseMemberPtr(5) != 7)
  error("Base useMemberPtr");
end
if (d.callGetMemberPtr(5) != 6)
  error("Base getMemberPtr");
end
d = MyMemberPtrDirector();
if (d.callUseMemberPtr(5) != 17)
  error("Director useMemberPtr");
end
if (d.callGetMemberPtr(5) != 7)
  error("Director getMemberPtr");
end
