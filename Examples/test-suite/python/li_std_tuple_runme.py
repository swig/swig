from li_std_tuple import *

def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

# Test by-value parameter with Python tuple input
r = sum_pair_values((3, 4.5))
check(r == 7.5)

# Test return value (should be a Python tuple)
r2 = make_int_double(10, 20.5)
check(isinstance(r2, tuple))
check(r2[0] == 10)
check(r2[1] == 20.5)

# Test both by-val and by-const-ref parameters
r3 = pass_tuples((1, 2.5), (10, 20.0))
check(isinstance(r3, tuple))
check(r3[0] == 11)
check(r3[1] == 22.5)
