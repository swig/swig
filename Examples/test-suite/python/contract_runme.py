import contract
from swig_test_utils import swig_check, swig_assert_raises

contract.test_preassert(1, 2)
try:
    contract.test_preassert(-1, 3)
    raise Exception("Failed! Preassertions are broken")
except RuntimeError:
    pass

contract.test_postassert(3)
try:
    contract.test_postassert(-3)
    raise Exception("Failed! Postassertions are broken")
except RuntimeError:
    pass

contract.test_prepost(2, 3)
contract.test_prepost(5, -4)
try:
    contract.test_prepost(-3, 4)
    raise Exception("Failed! Preassertions are broken")
except RuntimeError:
    pass

try:
    contract.test_prepost(4, -10)
    raise Exception("Failed! Postassertions are broken")

except RuntimeError:
    pass

swig_check(contract.test_arg_names(1, -1), 0)
with swig_assert_raises(RuntimeError):
    contract.test_arg_names(-1, 1)

swig_check(contract.test_result_name(-1), 1)
with swig_assert_raises(RuntimeError):
    contract.test_result_name(1)

f = contract.Foo()
f.test_preassert(4, 5)
try:
    f.test_preassert(-2, 3)
    raise Exception("Failed! Method preassertion.")
except RuntimeError:
    pass

f.test_postassert(4)
try:
    f.test_postassert(-4)
    raise Exception("Failed! Method postassertion")
except RuntimeError:
    pass

f.test_prepost(3, 4)
f.test_prepost(4, -3)
try:
    f.test_prepost(-4, 2)
    raise Exception("Failed! Method preassertion.")
except RuntimeError:
    pass

try:
    f.test_prepost(4, -10)
    raise Exception("Failed! Method postassertion.")
except RuntimeError:
    pass

contract.Foo.stest_prepost(4, 0)
try:
    contract.Foo.stest_prepost(-4, 2)
    raise Exception("Failed! Static method preassertion")
except RuntimeError:
    pass

try:
    contract.Foo.stest_prepost(4, -10)
    raise Exception("Failed! Static method posteassertion")
except RuntimeError:
    pass

b = contract.Bar()
try:
    b.test_prepost(2, -4)
    raise Exception("Failed! Inherited preassertion.")
except RuntimeError:
    pass


d = contract.D()
try:
    d.foo(-1, 1, 1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.foo(1, -1, 1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.foo(1, 1, -1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.foo(1, 1, 1, -1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.foo(1, 1, 1, 1, -1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass


try:
    d.bar(-1, 1, 1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.bar(1, -1, 1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.bar(1, 1, -1, 1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.bar(1, 1, 1, -1, 1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass
try:
    d.bar(1, 1, 1, 1, -1)
    raise Exception("Failed! Inherited preassertion (D).")
except RuntimeError:
    pass

e = contract.E()
e.m_i = 5
e.manipulate_arg1(5)
with swig_assert_raises(RuntimeError):
    e.manipulate_arg1(6)

# Namespace
my = contract.myClass(1)
try:
    my = contract.myClass(0)
    raise Exception("Failed! constructor preassertion")
except RuntimeError:
    pass
