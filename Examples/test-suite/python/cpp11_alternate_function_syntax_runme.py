import cpp11_alternate_function_syntax
from swig_test_utils import swig_check

a = cpp11_alternate_function_syntax.SomeStruct()

res = a.addNormal(4, 5)
if res != 9:
    raise RuntimeError("SomeStruct::addNormal(4,5) returns ", res, " should be 9.")

res = a.addAlternate(4, 5)
if res != 9:
    raise RuntimeError("SomeStruct::addAlternate(4,5) returns ", res, " should be 9.")

res = a.addAlternateConst(4, 5)
if res != 9:
    raise RuntimeError("SomeStruct::addAlternateConst(4,5) returns ", res, " should be 9.")

res = a.addAlternateNoExcept(4, 5)
if res != 9:
    raise RuntimeError("SomeStruct::addAlternateNoExcept(4,5) returns ", res, " should be 9.")

res = a.addAlternateConstNoExcept(4, 5)
if res != 9:
    raise RuntimeError("SomeStruct::addAlternateConstNoExcept(4,5) returns ", res, " should be 9.")

# Pointer and primitive reference trailing return types.
swig_check(a.int_constref(), 11)
swig_check(type(a.hello_const()).__name__, "Hello")
swig_check(str(a.int_ptr()).find("'int *'") > 0, True)
swig_check(str(a.int_ptr_ptr()).find("'int **'") > 0, True)
swig_check(str(a.int_ref()).find("'int *'") > 0, True)
swig_check(str(a.int_constptr()).find("'int *'") > 0, True)
swig_check(str(a.void_ptr()).find("'void *'") > 0, True)
swig_check(str(a.array_ref()).find("'int (*)[3]'") > 0, True)
swig_check(str(a.fn_ptr()).find("'int (*)(int)'") > 0, True)
swig_check(a.addAlternateMemberPtrParm(1, a.member_ptr()), 102)
