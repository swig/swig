import contract

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

# Namespace
my = contract.myClass(1)
try:
    my = contract.myClass(0)
    raise Exception("Failed! constructor preassertion")
except RuntimeError:
    pass
