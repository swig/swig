from member_funcptr_galore import *
from swig_test_utils import swig_check, swig_assert_raises

m = MemberFuncPtrs()
swig_check(m.aaa1(cvar.cc1), 0)
swig_check(m.aaa6(cvar.cc6), 0)
swig_check(m.aaa7(cvar.cc7), 0)
swig_check(m.bbb1(cvar.pp1), 0)
swig_check(m.bbb6(cvar.pp6), 0)
swig_check(m.bbb7(cvar.pp7), 0)
swig_check(call1(ADD_BY_VALUE, 1, 2), 3)

# A const reference to a member pointer is passed and returned as the member pointer
swig_check(m.aaa7(cvar.cc1), 0)
swig_check(m.aaa1(cvar.cc7), 0)

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
with swig_assert_raises(TypeError):
    m.aaa1(cvar.pp1)
with swig_assert_raises(TypeError):
    m.aaa7(cvar.pp7)
with swig_assert_raises(TypeError):
    m.bbb1(cvar.cc1)
with swig_assert_raises(TypeError):
    m.bbb7(cvar.cc7)
