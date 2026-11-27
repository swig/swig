#!/usr/bin/env ruby

require 'swig_assert'

require 'director_member_pointer'

class MyMemberPtrDirector < Director_member_pointer::MemberPtrDirector
  def useMemberPtr(m, x)
    Director_member_pointer::MemberPtrDirector.callMemberPtr(m, x + 10)
  end
  def useMemberPtrCref(m, x)
    Director_member_pointer::MemberPtrDirector.callMemberPtr(m, x + 20)
  end
  def getMemberPtr
    Director_member_pointer::MemberPtrDirector.addPtr
  end
  def getMemberPtrCref
    Director_member_pointer::MemberPtrDirector.addPtr
  end
end

d = Director_member_pointer::MemberPtrDirector.new
swig_assert_equal_simple(d.callUseMemberPtr(5), 7)
swig_assert_equal_simple(d.callUseMemberPtrCref(5), 7)
swig_assert_equal_simple(d.callGetMemberPtr(5), 6)
swig_assert_equal_simple(d.callGetMemberPtrCref(5), 6)
d = MyMemberPtrDirector.new
swig_assert_equal_simple(d.callUseMemberPtr(5), 17)
swig_assert_equal_simple(d.callUseMemberPtrCref(5), 27)
swig_assert_equal_simple(d.callGetMemberPtr(5), 7)
swig_assert_equal_simple(d.callGetMemberPtrCref(5), 7)
