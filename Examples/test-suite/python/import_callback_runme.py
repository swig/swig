import import_callback_x
import import_callback_y

x = import_callback_x.X()

# Sanity check
aa = x.call_xmethod(5)
if aa != -5:
    raise RuntimeError("Bad aa {}".format(aa))

# Callback within import_callback_x module
res = import_callback_x.go_for_it_x(3, x, import_callback_x.X.xmethod_cb_ptr) - 11
if res != x.call_xmethod(3):
    raise RuntimeError("Bad res {}".format(res))

# Callback across modules
# This uses the fallback string comparison in SwigPyPacked_Check()
res = import_callback_y.go_for_it_y(3, x, import_callback_x.X.xmethod_cb_ptr) - 111
if res != x.call_xmethod(3):
    raise RuntimeError("Bad res {}".format(res))
