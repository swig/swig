assert(callback.foobar(3, callback.foo()) == 3);
assert(callback.foobar(3, callback.foof()) == 9);
assert(callback.foobar(3, callback.A.bar()) == 6);
assert(callback.foobar_i(3, callback.FOO_I_Cb_Ptr()) == 3);
assert(callback.foobar_d(3.5, callback.FOO_D_Cb_Ptr()) == 3.5);
a = callback.A();
assert(callback.foobarm(3, a, callback.A.foom()) == -3);
assert(callback.apply_finger_cb(callback.Three(), callback.identity_finger_cb()) == callback.Three());
