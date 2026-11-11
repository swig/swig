import os
import pathlib

from cpp17_std_filesystem import *
from swig_test_utils import swig_assert, swig_assert_raises, swig_check


def check_flag(flag):
    if not flag:
        raise RuntimeError("Check failed")


def format_msg(p, p2):
    return "'{p}' != '{p2}', repr(p)={r}, repr(p2)={r2}".format(p=p, p2=p2, r=repr(p), r2=repr(p2))


def check(p, p2):
    swig_check(p, p2)


# Test the output typemap. The wrapped C++ functions
# makePath is expected to return a std::filesystem::path object
# (see li_std_filesystem.i). The output typemap should be in place to
# convert this std::filesystem::path object into a pathlib.Path object.
path = makePath("foo")
check_flag(isinstance(path, pathlib.Path))
check(str(path), "foo")

pathConstRef = makePathConstRef("foo")
check_flag(isinstance(pathConstRef, pathlib.Path))
check(str(pathConstRef), "foo")

# Each of these should return a reference to a wrapped
# std::filesystem::path object.
pathPtr = makePathPtr("foo")
check_flag(not isinstance(pathPtr, pathlib.Path))

pathRef = makePathRef("foo")
check_flag(not isinstance(pathRef, pathlib.Path))

# Now test various input typemaps. Each of the wrapped C++ functions
# (pathToStr, pathConstRefToStr) is expecting an argument of a
# different type (see li_std_filesystem.i). Typemaps should be in place to
# convert this pathlib.Path into the expected argument type.
check(pathToStr(path), "foo")
check(pathConstRefToStr(path), "foo")

# Similarly, each of the input typemaps should know what to do with a string.
check(pathToStr("foo"), "foo")
check(pathConstRefToStr("foo"), "foo")

# Similarly, each of the input typemaps should know what to do with a std::filesystem::path instance.
check(pathToStr(pathPtr), "foo")
check(pathConstRefToStr(pathPtr), "foo")

specialPath = pathlib.Path("/家/屋")
roundTripped = roundTrip(specialPath)
roundTrippedSquared = roundTrip(roundTripped)
lines = []
if specialPath != roundTripped:
    lines.append("specialPath, roundTripped: " + format_msg(specialPath, roundTripped))
if roundTripped != roundTrippedSquared:
    lines.append("roundTripped, roundTrippedSquared: " + format_msg(roundTripped, roundTrippedSquared))
if specialPath != roundTrippedSquared:
    lines.append("specialPath, roundTrippedSquared: " + format_msg(specialPath, roundTrippedSquared))
swig_assert(not lines, "\n".join(lines))

# A str that cannot be encoded as UTF-8, such as a filename that is not valid UTF-8
for fn in (pathToStr, pathConstRefToStr):
    with swig_assert_raises(UnicodeEncodeError):
        fn("caf\udce9.txt")

# Subclass PosixPath or WindowsPath as Path cannot be subclassed before Python 3.12
class RaisingPath(type(pathlib.Path("."))):
    def __str__(self):
        raise ValueError("__str__ raised")

for fn in (pathToStr, pathConstRefToStr):
    with swig_assert_raises(ValueError):
        fn(RaisingPath("foo"))

# None is not converted to a path
for fn in (pathToStr, pathConstRefToStr):
    with swig_assert_raises(TypeError):
        fn(None)

# Paths are wchar_t on Windows, so they do not need to be encoded or decoded as UTF-8
if os.name != "nt":
    for fn in (pathToStr, pathConstRefToStr):
        with swig_assert_raises(UnicodeEncodeError):
            fn(pathlib.Path("caf\udce9.txt"))
    for fn in (makeNonUtf8Path, makeNonUtf8PathConstRef):
        with swig_assert_raises(UnicodeDecodeError):
            fn()

# An exception raised creating the returned pathlib.Path is propagated, also when an output parameter is appended
for fn in (makePathAndValue, makePathConstRefAndValue):
    swig_check(fn(), [pathlib.Path("foo"), 1])

def raisingPathClass(*args):
    raise ValueError("pathlib.Path raised")

realPathClass = pathlib.Path
pathlib.Path = raisingPathClass
try:
    for fn in (makePathAndValue, makePathConstRefAndValue):
        with swig_assert_raises(ValueError):
            fn()
finally:
    pathlib.Path = realPathClass

# Overloaded functions accept the same arguments as the "in" typemaps
for fn in (pathOrInt, pathConstRefOrInt):
    swig_check(fn(1), "int")
    swig_check(fn("foo"), "path")
    swig_check(fn(pathlib.Path("foo")), "path")
    swig_check(fn(makePathPtr("foo")), "path")
    with swig_assert_raises(TypeError):
        fn(None)

# A str is passed to an overload taking a string ahead of one taking a path
swig_check(pathOrString("foo"), "string")
swig_check(pathOrString(pathlib.Path("foo")), "path")
swig_check(pathOrString(makePathPtr("foo")), "path")
