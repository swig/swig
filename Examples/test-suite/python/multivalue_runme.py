import multivalue

q, r = multivalue.divide_l(37, 5);
if q != 7:
    raise RuntimeError("Test divide_l quotient")
if r != 2:
    raise RuntimeError("Test divide_l remainder")

q, r = multivalue.divide_v(41, 7);
if q != 5:
    raise RuntimeError("Test divide_v quotient")
if r != 6:
    raise RuntimeError("Test divide_v remainder")

q, r = multivalue.divide_l(91, 13);
if q != 7:
    raise RuntimeError("Test divide_mv quotient")
if r != 0:
    raise RuntimeError("Test divide_mv remainder")
