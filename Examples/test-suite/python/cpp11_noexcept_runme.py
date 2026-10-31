import cpp11_noexcept
from swig_test_utils import swig_check

f = cpp11_noexcept.NoExceptFuncPtrReturn()
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr1(), 1), "2")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr2(), 2), "3")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr3(), 3), "4")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr4(), 4), "5")
swig_check(cpp11_noexcept.noexceptCallStringFunc(f.ptr5(), 5), "6")
