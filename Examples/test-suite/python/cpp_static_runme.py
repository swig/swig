#!/usr/bin/evn python
from cpp_static import *
StaticFunctionTest.static_func()
StaticFunctionTest.static_func_2(1)
StaticFunctionTest.static_func_3(1,2)
StaticMemberTest.static_int = 10
assert StaticMemberTest.static_int == 10
