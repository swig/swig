from li_std_unique_ptr_deleter import *

def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

# Test creating and passing a unique_ptr with custom deleter
w = make_widget(42)
check(w is not None)

val = widget_value(w)
check(val == 42)
