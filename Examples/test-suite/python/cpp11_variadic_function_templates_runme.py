from cpp11_variadic_function_templates import *

ec = EmplaceContainer()
ec.emplace(A())
ec.emplace(A(), B())
ec.emplace(A(), B(), C())
ec.emplace(A(), B(), C(), D())

def check(expected, got):
    if expected != got:
        raise RuntimeError("failed: {} != {}".format(expected, got))

a = A()
b = B()
c = C()
check(variadicmix1(), 20)
check(variadicmix1(a), 20)
check(variadicmix1(a, b), 10)
check(variadicmix1(a, b, c), 20)
check(variadicmix1(11, 22), 10)

check(pack_then_deduced(1, 2, 3.5), 21)
check(pack_then_deduced(4.5), 1)

ph = PackHolderIS()
check(ph.both(1, 2, 3.5), 21)
check(ph.own(1.5, 2.5, 3.5), 3)
