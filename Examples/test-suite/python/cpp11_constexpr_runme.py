from cpp11_constexpr import *
from swig_test_utils import swig_check, swig_assert_raises

# Static constexpr member pointers are passed to a function taking their type
swig_check(takeNonConstPtr(MemberPointerConstants.NonConstPtr), 1)
swig_check(takeConstPtr(MemberPointerConstants.ConstPtr), 2)
swig_check(takeVolatilePtr(MemberPointerConstants.VolatilePtr), 3)
swig_check(takeConstRefPtr(MemberPointerConstants.ConstRefPtr), 4)
swig_check(takeConstNoexceptPtr(MemberPointerConstants.ConstNoexceptPtr), 5)
swig_check(takeConstStringPtr(MemberPointerConstants.ConstStringPtr), "six")
swig_check(takeConstDataPtr(MemberPointerConstants.ConstDataPtr), 7)
swig_check(takeTypedefPtr(MemberPointerConstants.TypedefPtr), 2)
swig_check(takeConstPtr(MemberPointerConstants.TypedefPtr), 2)

# A function taking another member pointer type rejects them
with swig_assert_raises(TypeError):
    takeNonConstPtr(MemberPointerConstants.ConstPtr)
with swig_assert_raises(TypeError):
    takeConstPtr(MemberPointerConstants.NonConstPtr)
with swig_assert_raises(TypeError):
    takeConstPtr(MemberPointerConstants.VolatilePtr)
with swig_assert_raises(TypeError):
    takeConstPtr(MemberPointerConstants.ConstRefPtr)
with swig_assert_raises(TypeError):
    takeNonConstPtr(MemberPointerConstants.ConstNoexceptPtr)
with swig_assert_raises(TypeError):
    takeConstPtr(MemberPointerConstants.ConstStringPtr)
with swig_assert_raises(TypeError):
    takeConstPtr(MemberPointerConstants.ConstDataPtr)
with swig_assert_raises(TypeError):
    takeNonConstPtr(MemberPointerConstants.TypedefPtr)
