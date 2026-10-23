from funcptr_cpp import *
from swig_test_utils import swig_check, swig_assert_raises

if call1(ADD_BY_VALUE, 10, 11) != 21:
    raise RuntimeError
if call2(ADD_BY_POINTER, 12, 13) != 25:
    raise RuntimeError
if call3(ADD_BY_REFERENCE, 14, 15) != 29:
    raise RuntimeError
if call1(ADD_BY_VALUE_C, 2, 3) != 5:
    raise RuntimeError

if callconst1(ADD_BY_VALUE_C, 2, 3) != 5:
    raise RuntimeError

holder = AddByValueHolder()
swig_check(holder.byValueMethod(4, 5), 9)
swig_check(holder.byValueConstMethod(5, 6), 11)
swig_check(holder.byValueRef(6, 7), 13)
swig_check(addByValueRef(10, 11), 21)

swig_check(callref1(ADD_BY_VALUE, 1, 2), 3)
swig_check(callref2(ADD_BY_VALUE, 2, 3), 5)
swig_check(callref1(getAddByValueRef1(), 3, 4), 7)
swig_check(callref2(getAddByValueRef2(), 4, 5), 9)
refholder = AddByValueRefHolder(ADD_BY_VALUE)
swig_check(refholder.call(5, 6), 11)
swig_check(refholder.fnRef(6, 7), 13)
with swig_assert_raises(TypeError):
    callref1(None, 1, 2)

swig_check(arrayRefSum(getArrayRef1()), 100)
swig_check(arrayRefSum(getArrayRef2()), 100)
