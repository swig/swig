import director_member_pointer
from swig_test_utils import swig_check

class MyMemberPtrDirector(director_member_pointer.MemberPtrDirector):
    def useMemberPtr(self, m, x):
        return director_member_pointer.MemberPtrDirector.callMemberPtr(m, x + 10)
    def useMemberPtrCref(self, m, x):
        return director_member_pointer.MemberPtrDirector.callMemberPtr(m, x + 20)
    def getMemberPtr(self):
        return director_member_pointer.MemberPtrDirector.addPtr()
    def getMemberPtrCref(self):
        return director_member_pointer.MemberPtrDirector.addPtr()

d = director_member_pointer.MemberPtrDirector()
swig_check(d.callUseMemberPtr(5), 7)
swig_check(d.callUseMemberPtrCref(5), 7)
swig_check(d.callGetMemberPtr(5), 6)
swig_check(d.callGetMemberPtrCref(5), 6)
d = MyMemberPtrDirector()
swig_check(d.callUseMemberPtr(5), 17)
swig_check(d.callUseMemberPtrCref(5), 27)
swig_check(d.callGetMemberPtr(5), 7)
swig_check(d.callGetMemberPtrCref(5), 7)
