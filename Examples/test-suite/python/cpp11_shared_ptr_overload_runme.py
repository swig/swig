import cpp11_shared_ptr_overload
from cpp11_shared_ptr_overload import MyType

# ref
ret = cpp11_shared_ptr_overload.UseA(MyType("123"))
if ret != "123 ref": raise RuntimeError("UseA fail:" + ret)

ret = cpp11_shared_ptr_overload.UseB(0, MyType("123"))
if ret != "123 ref": raise RuntimeError("UseB fail:" + ret)

ret = cpp11_shared_ptr_overload.UseC(0, MyType("123"), MyType("456"))
if ret != "123 ref": raise RuntimeError("UseC fail:" + ret)

# sharedptr
ret = cpp11_shared_ptr_overload.UseX(MyType("123"))
if ret != "123 sharedptr": raise RuntimeError("UseX fail:" + ret)

ret = cpp11_shared_ptr_overload.UseY(0, MyType("123"))
if ret != "123 sharedptr": raise RuntimeError("UseY fail:" + ret)

ret = cpp11_shared_ptr_overload.UseZ(0, MyType("123"), MyType("456"))
if ret != "123 sharedptr": raise RuntimeError("UseZ fail:" + ret)

# Combo1-4
ret = cpp11_shared_ptr_overload.Combo1(MyType("XXX"))
if ret != "XXXCombo1": raise RuntimeError("Combo1 fail:" + ret)

ret = cpp11_shared_ptr_overload.Combo2(MyType("XXX"))
if ret != "XXXCombo2": raise RuntimeError("Combo2 fail:" + ret)

ret = cpp11_shared_ptr_overload.Combo3(MyType("XXX"))
if ret != "XXXCombo3": raise RuntimeError("Combo3 fail:" + ret)

ret = cpp11_shared_ptr_overload.Combo4(MyType("XXX"))
if ret != "XXXCombo4": raise RuntimeError("Combo4 fail:" + ret)

# Combo5-7
ret = cpp11_shared_ptr_overload.Combo5(MyType("XXX"))
if ret != "XXXCombo5": raise RuntimeError("Combo5 fail:" + ret)

ret = cpp11_shared_ptr_overload.Combo6(MyType("XXX"))
if ret != "XXXCombo6": raise RuntimeError("Combo6 fail:" + ret)

ret = cpp11_shared_ptr_overload.Combo7(MyType("XXX"))
if ret != "XXXCombo7": raise RuntimeError("Combo7 fail:" + ret)
