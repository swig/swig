from python_flatstaticmethod import *
import inspect

# This testcase tests C++ class static functions when using legacy "flattened"
# staticmethod access, A_bar, as well as the normal staticmethod access, A.bar.


def check(got, expected):
    if got != expected:
        raise RuntimeError("\ngot :{}\nwant:{}\n".format(got, expected))

if A_bar(2) != 4:
    raise RuntimeError

if A.bar(2) != 4:
    raise RuntimeError

# %callback
if foobar(3, A_bar) != A_bar(3):
    raise RuntimeError

if foobar(3, A.bar) != A_bar(3):
    raise RuntimeError

# kwargs
if A_pub() != 1:
    raise RuntimeError

if A_pub(b=2) != 3:
    raise RuntimeError

if A_pub(b=10,a=20) != 30:
    raise RuntimeError

if A.pub() != 1:
    raise RuntimeError

if A.pub(b=2) != 3:
    raise RuntimeError

if A.pub(b=10,a=20) != 30:
    raise RuntimeError

check(inspect.getdoc(A_func0static),
    "A_func0static(e, arg2, hello, f=2) -> int")
check(inspect.getdoc(A_func1static),
    "A_func1static(A e, short arg2, Tuple hello, double f=2) -> int")

# overloaded static functions
if A_over(3) != "over:int":
    raise RuntimeError("A::over(int)")

if A_over(3.0) != "over:double":
    raise RuntimeError("A::over(double)")

if A_over("hello") != "over:char *":
    raise RuntimeError("A::over(char *)")

if A.over(3) != "over:int":
    raise RuntimeError("A::over(int)")

if A.over(3.0) != "over:double":
    raise RuntimeError("A::over(double)")

if A.over("hello") != "over:char *":
    raise RuntimeError("A::over(char *)")

# default args
if A_defargs() != 30:
    raise RuntimeError

if A_defargs(1) != 21:
    raise RuntimeError

if A_defargs(1, 2) != 3:
    raise RuntimeError

if A.defargs() != 30:
    raise RuntimeError

if A.defargs(1) != 21:
    raise RuntimeError

if A.defargs(1, 2) != 3:
    raise RuntimeError

# %extend
if A_staticextended(11) != 11:
    raise RuntimeError

if A.staticextended(11) != 11:
    raise RuntimeError
