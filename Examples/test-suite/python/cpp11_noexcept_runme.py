import cpp11_noexcept
from swig_test_utils import swig_assert, swig_check

f = cpp11_noexcept.NoExceptFuncPtrReturn()
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr1(), 1), "2")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr2(), 2), "3")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr3(), 3), "4")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr4(), 4), "5")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr5(), 5), "6")

swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(cpp11_noexcept.noexceptGetAddTwo(), 1), 3)
# A pointer to a noexcept function converts to a pointer to the function without noexcept
swig_check(cpp11_noexcept.noexceptCallIntFunc(cpp11_noexcept.noexceptGetAddTwo(), 1), 3)
m = cpp11_noexcept.NoExceptFuncPtrMember()
swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(m.ptr, 2), 4)
m.ptr = cpp11_noexcept.noexceptGetAddTwo()
swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(m.ptr, 3), 5)
swig_assert("std::string (*(*)() noexcept)(int)" in repr(cpp11_noexcept.noexceptGetGetter()), "noexcept missing from the type")

# noexcept in an abstract declarator
swig_check(cpp11_noexcept.noexceptCallUnnamed(cpp11_noexcept.noexceptGetAddTwo(), 4), 6)
swig_check(cpp11_noexcept.noexceptCallDefault(5), 7)
swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(cpp11_noexcept.noexceptGetAddTwoTrailing(), 6), 8)
h = cpp11_noexcept.NoExceptFuncPtrHolder(cpp11_noexcept.noexceptGetAddTwo())
swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(h.ptr, 7), 9)
member = cpp11_noexcept.NoExceptMemberFunc()
swig_check(cpp11_noexcept.noexceptCallMemberFunc(cpp11_noexcept.noexceptGetAddThree(), member, 1), 4)

# noexcept in a function typedef or alias
swig_check(cpp11_noexcept.noexceptCallFuncType(cpp11_noexcept.noexceptGetAddTwo(), 1), 3)
swig_check(cpp11_noexcept.noexceptCallFuncPtrAlias(cpp11_noexcept.noexceptGetAddTwo(), 2), 4)
swig_check(cpp11_noexcept.noexceptCallFuncPtrTrailing(cpp11_noexcept.noexceptGetAddTwo(), 3), 5)
swig_check(cpp11_noexcept.noexceptCallMemberFuncPtrAlias(cpp11_noexcept.noexceptGetAddThree(), member, 2), 5)
swig_check(cpp11_noexcept.noexceptCallMemberFuncPtrTrailing(cpp11_noexcept.noexceptGetAddThree(), member, 3), 6)
swig_check(cpp11_noexcept.NoExceptFuncTypeMember().addFour(1), 5)

# The declarators after the first in a list
m = cpp11_noexcept.NoExceptFuncPtrMembers()
m.ptr2 = cpp11_noexcept.noexceptGetAddTwo2()
swig_check(cpp11_noexcept.noexceptCallNoExceptFunc(m.ptr2, 4), 6)
swig_check(cpp11_noexcept.noexceptCallFuncType2(cpp11_noexcept.noexceptGetAddTwo2(), 5), 7)

# The in typemap with locals supplies the function pointer
swig_check(cpp11_noexcept.noexceptCallLocals(8), 10)
