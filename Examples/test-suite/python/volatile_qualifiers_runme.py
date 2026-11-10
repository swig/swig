from volatile_qualifiers import *
from swig_test_utils import swig_check

p = volatile_int_ptr_return()
swig_check(int_ptr(p), 50)
swig_check(const_int_ptr(p), 50)
swig_check(volatile_int_ptr(p), 50)
swig_check(const_volatile_int_ptr(p), 50)
swig_check(int_volatile_ptr(p), 50)
swig_check(volatile_int_value(5), 5)
swig_check(const_volatile_int_value(6), 6)
swig_check(volatile_int_ref(p), 50)
swig_check(const_volatile_int_ref(6), 6)

swig_check(char_ptr("four"), 4)
swig_check(const_char_ptr("three"), 5)
swig_check(volatile_char_ptr("four"), 4)
swig_check(const_volatile_char_ptr("four"), 4)
swig_check(char_volatile_ptr("four"), 4)

item = Item(7)
swig_check(item_ptr(item), 7)
swig_check(const_item_ptr(item), 7)
swig_check(volatile_item_ptr(item), 7)
swig_check(const_volatile_item_ptr(item), 7)
swig_check(item_volatile_ptr(item), 7)
swig_check(volatile_item_ref(item), 7)
swig_check(const_volatile_item_ref(item), 7)
swig_check(volatile_item_value(item), 7)
swig_check(const_volatile_item_value(item), 7)

swig_check(const_volatile_char_ptr_return(), "return")
swig_check(volatile_item_ptr_return(item).x, 7)
swig_check(const_volatile_item_ref_return(item).x, 7)

cvar.global_volatile_int = 3
swig_check(cvar.global_volatile_int, 3)
swig_check(cvar.global_const_volatile_int, 2)
cvar.global_char_volatile_ptr = "four"
swig_check(cvar.global_char_volatile_ptr, "four")
cvar.global_item_volatile_ptr = item
swig_check(cvar.global_item_volatile_ptr.x, 7)

m = Members()
swig_check(m.volatile_int, 10)
m.volatile_int = 11
swig_check(m.volatile_int, 11)
swig_check(m.const_volatile_int, 20)
m.char_volatile_ptr = "four"
swig_check(m.char_volatile_ptr, "four")
m.volatile_item_ptr = item
swig_check(m.volatile_item_ptr.x, 7)
m.item_volatile_ptr = item
swig_check(m.item_volatile_ptr.x, 7)

swig_check(cvar.Members_static_volatile_int, 30)
cvar.Members_static_volatile_int = 31
swig_check(cvar.Members_static_volatile_int, 31)
swig_check(cvar.Members_static_const_volatile_int, 40)
cvar.Members_static_char_volatile_ptr = "four"
swig_check(cvar.Members_static_char_volatile_ptr, "four")
cvar.Members_static_item_volatile_ptr = item
swig_check(cvar.Members_static_item_volatile_ptr.x, 7)
