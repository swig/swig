from python_overload_simple_cast import *

import sys

class Ai:

    def __init__(self, x):
        self.x = x

    def __int__(self):
        return self.x

    def __index__(self):
        return self.x

class Ad:

    def __init__(self, x):
        self.x = x

    def __float__(self):
        return self.x

ai = Ai(4)

ad = Ad(5.0)
add = Ad(5.5)

try:
    fint(add)
    good = 0
except:
    good = 1

if not good:
    raise RuntimeError("fint(int)")


if fint(ad) != "fint:int":
    raise RuntimeError("fint(int)")

if fdouble(ad) != "fdouble:double":
    raise RuntimeError("fdouble(double)")

if fint(ai) != "fint:int":
    raise RuntimeError("fint(int)")

if fint(5.0) != "fint:int":
    raise RuntimeError("fint(int)")

if fint(3) != "fint:int":
    raise RuntimeError("fint(int)")
if fint(3.0) != "fint:int":
    raise RuntimeError("fint(int)")

if fdouble(ad) != "fdouble:double":
    raise RuntimeError("fdouble(double)")
if fdouble(3) != "fdouble:double":
    raise RuntimeError("fdouble(double)")
if fdouble(3.0) != "fdouble:double":
    raise RuntimeError("fdouble(double)")

if fid(3, 3.0) != "fid:intdouble":
    raise RuntimeError("fid:intdouble")

if fid(3.0, 3) != "fid:doubleint":
    raise RuntimeError("fid:doubleint")

if fid(ad, ai) != "fid:doubleint":
    raise RuntimeError("fid:doubleint")

if fid(ai, ad) != "fid:intdouble":
    raise RuntimeError("fid:intdouble")


if foo(3) != "foo:int":
    raise RuntimeError("foo(int)")

if foo(3.0) != "foo:double":
    raise RuntimeError("foo(double)")

if foo("hello") != "foo:char *":
    raise RuntimeError("foo(char *)")

f = Foo()
b = Bar()

if foo(f) != "foo:Foo *":
    raise RuntimeError("foo(Foo *)")

if foo(b) != "foo:Bar *":
    raise RuntimeError("foo(Bar *)")

v = malloc_void(32)

if foo(v) != "foo:void *":
    raise RuntimeError("foo(void *)")

s = Spam()

if s.foo(3) != "foo:int":
    raise RuntimeError("Spam::foo(int)")

if s.foo(3.0) != "foo:double":
    raise RuntimeError("Spam::foo(double)")

if s.foo("hello") != "foo:char *":
    raise RuntimeError("Spam::foo(char *)")

if s.foo(f) != "foo:Foo *":
    raise RuntimeError("Spam::foo(Foo *)")

if s.foo(b) != "foo:Bar *":
    raise RuntimeError("Spam::foo(Bar *)")

if s.foo(v) != "foo:void *":
    raise RuntimeError("Spam::foo(void *)")

if Spam.bar(3) != "bar:int":
    raise RuntimeError("Spam::bar(int)")

if Spam.bar(3.0) != "bar:double":
    raise RuntimeError("Spam::bar(double)")

if Spam.bar("hello") != "bar:char *":
    raise RuntimeError("Spam::bar(char *)")

if Spam.bar(f) != "bar:Foo *":
    raise RuntimeError("Spam::bar(Foo *)")

if Spam.bar(b) != "bar:Bar *":
    raise RuntimeError("Spam::bar(Bar *)")

if Spam.bar(v) != "bar:void *":
    raise RuntimeError("Spam::bar(void *)")

# Test constructors

s = Spam()
if s.type != "none":
    raise RuntimeError("Spam()")

s = Spam(3)
if s.type != "int":
    raise RuntimeError("Spam(int)")

s = Spam(3.4)
if s.type != "double":
    raise RuntimeError("Spam(double)")

s = Spam("hello")
if s.type != "char *":
    raise RuntimeError("Spam(char *)")

s = Spam(f)
if s.type != "Foo *":
    raise RuntimeError("Spam(Foo *)")

s = Spam(b)
if s.type != "Bar *":
    raise RuntimeError("Spam(Bar *)")

s = Spam(v)
if s.type != "void *":
    raise RuntimeError("Spam(void *)")


# nextafter: ++ and -- operators for float, off by one LSB
# nextafter was released in Python 3.9
if sys.version_info[0:2] >= (3, 9):
    from math import inf, nextafter
else:
    # workaround: try to load nextafter from numpy if available
    try:
        # Skip numpy workaround for consistency in testing
        if True:
            raise RuntimeError("skip test")
        from numpy import nextafter
    except:
        # else just disable this tests
        def nextafter(x, y):
            return None

    # math.inf was added in Python 3.5
    inf = float('inf')

def exceptMatch(fun, arg, res, msg):
    if arg is None or res is None:
        # nextafter is missing, so skipping this test
        return
    if fun(arg) != res:
        raise RuntimeError(msg)

def exceptTypeError(fun, arg, msg):
    if arg is None:
        # nextafter is missing, so skipping this test
        return
    try:
        fun(arg)
        raise RuntimeError(msg)
    except TypeError:
        pass

# x86_64: long is 32bit on MSVC but 64bit on *nix
if not(sizeof_long() in [4, 8]):
    raise RuntimeError("Unexpected size for long")

# unsigned long
ulmax = 2**32 - 1
ulmin = 0
ulmaxd = float(2**32 - 1)
ulmind = 0.0
if sizeof_long() == 8:
    ulmax = 2**64 - 1
    ulmaxd = nextafter(float(2**64), 0.0)

exceptMatch(as_ul, ulmin, ulmin, "as_ul(ulmin)")
exceptMatch(as_ul, ulmax, ulmax, "as_ul(ulmax)")
exceptMatch(as_ul, ulmind, ulmind, "as_ul(ulmind)")
exceptMatch(as_ul, ulmaxd, ulmaxd, "as_ul(ulmaxd)")

exceptTypeError(as_ul, ulmin - 1, "as_ul(ulmin - 1)")
exceptTypeError(as_ul, ulmax + 1, "as_ul(ulmax + 1)")
exceptTypeError(as_ul, nextafter(ulmind, -inf), "as_ul(ulmind - LSB)")
exceptTypeError(as_ul, nextafter(ulmaxd, inf), "as_ul(ulmaxd + LSB)")

# long
lmax = 2**31 - 1
lmin = -2**31
lmaxd = float(2**31 - 1)
lmind = float(-2**31)
lmaxd_v = lmaxd # expected value after the cast
lmind_v = lmind
if sys.version_info[0:2] < (3, 10):
    # PyLong_AsLong(float) truncated the input before 3.10
    lmaxd = nextafter(float(2**31), 0.0)
    lmind = nextafter(float(-2**31 - 1), 0.0)
    lmaxd_v = float(2**31 - 1)
    lmind_v = float(-2**31)
if sizeof_long() == 8:
    lmax = 2**63 - 1
    lmin = -2**63
    lmaxd = nextafter(float(2**63), 0.0)
    lmind = float(-2**63)
    lmaxd_v = lmaxd
    lmind_v = lmind

exceptMatch(as_l, lmin, lmin, "as_l(lmin)")
exceptMatch(as_l, lmax, lmax, "as_l(lmax)")
exceptMatch(as_l, lmind, lmind_v, "as_l(lmind)")
exceptMatch(as_l, lmaxd, lmaxd_v, "as_l(lmaxd)")

exceptTypeError(as_l, lmin - 1, "as_l(lmin - 1)")
exceptTypeError(as_l, lmax + 1, "as_l(lmax + 1)")
exceptTypeError(as_l, nextafter(lmind, -inf), "as_l(lmind - LSB)")
exceptTypeError(as_l, nextafter(lmaxd, inf), "as_l(lmaxd + LSB)")

# unsigned long long
ullmax = 2**64 - 1
ullmin = 0
ullmaxd = float(2**53) # 64 bit double significand
ullmind = 0.0
if sizeof_long() == 8:
    ullmaxd = nextafter(float(2**64), 0.0)

exceptMatch(as_ull, ullmin, ullmin, "as_ull(ullmin)")
exceptMatch(as_ull, ullmax, ullmax, "as_ull(ullmax)")
exceptMatch(as_ull, ullmind, ullmind, "as_ull(ullmind)")
exceptMatch(as_ull, ullmaxd, ullmaxd, "as_ull(ullmaxd)")

exceptTypeError(as_ull, ullmin - 1, "as_ull(ullmin - 1)")
exceptTypeError(as_ull, ullmax + 1, "as_ull(ullmax + 1)")
exceptTypeError(as_ull, nextafter(ullmind, -inf), "as_ull(ullmind - LSB)")
exceptTypeError(as_ull, nextafter(ullmaxd, inf), "as_ull(ullmaxd + LSB)")

# long long
llmax = 2**63 - 1
llmin = -2**63
llmaxd = float(2**53) # 64 bit double significand
llmind = float(-2**53)
if sizeof_long() == 8:
    llmaxd = nextafter(float(2**63), 0.0)
    llmind = float(-2**63)

exceptMatch(as_ll, llmin, llmin, "as_ll(llmin)")
exceptMatch(as_ll, llmax, llmax, "as_ll(llmax)")
exceptMatch(as_ll, llmind, llmind, "as_ll(llmind)")
exceptMatch(as_ll, llmaxd, llmaxd, "as_ll(llmaxd)")

exceptTypeError(as_ll, llmin - 1, "as_ll(llmin - 1)")
exceptTypeError(as_ll, llmax + 1, "as_ll(llmax + 1)")
exceptTypeError(as_ll, nextafter(llmind, -inf), "as_ll(llmind - LSB)")
exceptTypeError(as_ll, nextafter(llmaxd, inf), "as_ll(llmaxd + LSB)")


free_void(v)
