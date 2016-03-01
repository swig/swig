#!/usr/bin/evn python
from cpp_static import *


def is_new_style_class(cls):
    return hasattr(cls, "__class__")

if is_new_style_class(StaticFunctionTest):
    StaticFunctionTest.static_func()
    StaticFunctionTest.static_func_2(1)
    StaticFunctionTest.static_func_3(1, 2)
else:
    StaticFunctionTest().static_func()
    StaticFunctionTest().static_func_2(1)
    StaticFunctionTest().static_func_3(1, 2)
StaticMemberTest.static_int = 10
assert StaticMemberTest.static_int == 10
