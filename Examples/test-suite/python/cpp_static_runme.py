#!/usr/bin/evn python
from cpp_static import *


StaticFunctionTest.static_func()
StaticFunctionTest.static_func_2(1)
StaticFunctionTest.static_func_3(1, 2)

if is_python_builtin():
  if not StaticMemberTest.static_int == 99: raise RuntimeError("static_int not 99")
  if not StaticMemberTest.grab_int() == 99: raise RuntimeError("static_int not 99")
  StaticMemberTest.static_int = 10
  if not StaticMemberTest.static_int == 10: raise RuntimeError("static_int not 10")
  if not StaticMemberTest.grab_int() == 10: raise RuntimeError("static_int not 10")

  if not StaticBase.statty == 11: raise RuntimeError("statty not 11")
  if not StaticBase.grab_statty_base() == 11: raise RuntimeError("statty not 11")
  if not StaticDerived.statty == 111: raise RuntimeError("statty not 111")
  if not StaticDerived.grab_statty_derived() == 111: raise RuntimeError("statty not 111")
  StaticBase.statty = 22
  StaticDerived.statty = 222
  if not StaticBase.statty == 22: raise RuntimeError("statty not 22")
  if not StaticBase.grab_statty_base() == 22: raise RuntimeError("statty not 22")
  if not StaticDerived.statty == 222: raise RuntimeError("statty not 222")
  if not StaticDerived.grab_statty_derived() == 222: raise RuntimeError("statty not 222")

  # Restore
  StaticMemberTest.static_int = 99
  StaticBase.statty = 11
  StaticDerived.statty = 111

if not cvar.StaticMemberTest_static_int == 99: raise RuntimeError("cvar static_int not 99")
if not StaticMemberTest.grab_int() == 99: raise RuntimeError("cvar static_int not 99")
cvar.StaticMemberTest_static_int = 10
if not cvar.StaticMemberTest_static_int == 10: raise RuntimeError("cvar static_int not 10")
if not StaticMemberTest.grab_int() == 10: raise RuntimeError("cvar static_int not 10")

if not cvar.StaticBase_statty == 11: raise RuntimeError("cvar statty not 11")
if not StaticBase.grab_statty_base() == 11: raise RuntimeError("cvar statty not 11")
if not cvar.StaticDerived_statty == 111: raise RuntimeError("cvar statty not 111")
if not StaticDerived.grab_statty_derived() == 111: raise RuntimeError("cvar statty not 111")
cvar.StaticBase_statty = 22
cvar.StaticDerived_statty = 222
if not cvar.StaticBase_statty == 22: raise RuntimeError("cvar statty not 22")
if not StaticBase.grab_statty_base() == 22: raise RuntimeError("cvar statty not 22")
if not cvar.StaticDerived_statty == 222: raise RuntimeError("cvar statty not 222")
if not StaticDerived.grab_statty_derived() == 222: raise RuntimeError("cvar statty not 222")

# Restore
cvar.StaticMemberTest_static_int = 99
cvar.StaticBase_statty = 11
cvar.StaticDerived_statty = 111

# Low-level layer testing
if not is_python_builtin():
    from cpp_static import _cpp_static
    if not _cpp_static.StaticMemberTest_static_int_get() == 99: raise RuntimeError("low-level static_int not 99")
    if not StaticMemberTest.grab_int() == 99: raise RuntimeError("low-level static_int not 99")
    _cpp_static.StaticMemberTest_static_int_set(10)
    if not _cpp_static.StaticMemberTest_static_int_get() == 10: raise RuntimeError("low-level static_int not 10")
    if not StaticMemberTest.grab_int() == 10: raise RuntimeError("low-level static_int not 10")

    if not _cpp_static.StaticBase_statty_get() == 11: raise RuntimeError("low-level statty not 11")
    if not StaticBase.grab_statty_base() == 11: raise RuntimeError("low-level statty not 11")
    if not _cpp_static.StaticDerived_statty_get() == 111: raise RuntimeError("low-level statty not 111")
    if not StaticDerived.grab_statty_derived() == 111: raise RuntimeError("low-level statty not 111")
    _cpp_static.StaticBase_statty_set(22)
    _cpp_static.StaticDerived_statty_set(222)
    if not _cpp_static.StaticBase_statty_get() == 22: raise RuntimeError("low-level statty not 22")
    if not StaticBase.grab_statty_base() == 22: raise RuntimeError("low-level statty not 22")
    if not _cpp_static.StaticDerived_statty_get() == 222: raise RuntimeError("low-level statty not 222")
    if not StaticDerived.grab_statty_derived() == 222: raise RuntimeError("low-level statty not 222")
