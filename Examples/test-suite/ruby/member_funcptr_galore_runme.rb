#!/usr/bin/env ruby

require 'swig_assert'
require 'member_funcptr_galore'

include Member_funcptr_galore

def check_type_error(name)
  begin
    yield
    raise RuntimeError, "#{name} accepted"
  rescue TypeError
  end
end

m = MemberFuncPtrs.new
swig_assert_equal('m.aaa1(Member_funcptr_galore.cc1)', '0', binding)
swig_assert_equal('m.aaa6(Member_funcptr_galore.cc6)', '0', binding)
swig_assert_equal('m.aaa7(Member_funcptr_galore.cc7)', '0', binding)
swig_assert_equal('m.bbb1(Member_funcptr_galore.pp1)', '0', binding)
swig_assert_equal('m.bbb6(Member_funcptr_galore.pp6)', '0', binding)
swig_assert_equal('m.bbb7(Member_funcptr_galore.pp7)', '0', binding)
swig_assert_equal('Member_funcptr_galore.call1(ADD_BY_VALUE, 1, 2)', '3', binding)

# A const reference to a member pointer is passed and returned as the member pointer
swig_assert_equal('m.aaa7(Member_funcptr_galore.cc1)', '0', binding)
swig_assert_equal('m.aaa1(Member_funcptr_galore.cc7)', '0', binding)

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
check_type_error("aaa1 with pp1") { m.aaa1(Member_funcptr_galore.pp1) }
check_type_error("aaa7 with pp7") { m.aaa7(Member_funcptr_galore.pp7) }
check_type_error("bbb1 with cc1") { m.bbb1(Member_funcptr_galore.cc1) }
check_type_error("bbb7 with cc7") { m.bbb7(Member_funcptr_galore.cc7) }
