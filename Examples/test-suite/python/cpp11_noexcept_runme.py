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
