import pathlib

from cpp17_std_filesystem import *


def check_flag(flag):
    if not flag:
        raise RuntimeError("Check failed")


def format_msg(p, p2):
    return "'{p}' != '{p2}', repr(p)={r}, repr(p2)={r2}".format(p=p, p2=p2, r=repr(p), r2=repr(p2))


def check(p, p2):
    assert p == p2, format_msg(p, p2)


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
assert not lines, "\n".join(lines)
