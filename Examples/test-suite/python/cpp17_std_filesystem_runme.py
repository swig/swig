import pathlib

from cpp17_std_filesystem import *

if not is_cplusplus17():
    exit(0)  # No-op


def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

# Test the output typemap. The wrapped C++ functions
# makePath is expected to return a std::filesystem::path object
# (see li_std_filesystem.i). The output typemap should be in place to
# convert this std::filesystem::path object into a pathlib.Path object.
path = makePath("foo")
check(isinstance(path, pathlib.Path))
check(str(path) == "foo")

#
# Each of these should return a reference to a wrapped
# std::filesystem::path object.
#
pathPtr = makePathPtr("foo")
check(not isinstance(pathPtr, pathlib.Path))

pathRef = makePathRef("foo")
check(not isinstance(pathRef, pathlib.Path))

pathConstRef = makePathConstRef("foo")
check(not isinstance(pathConstRef, pathlib.Path))

#
# Now test various input typemaps. Each of the wrapped C++ functions
# (pathToStr, pathConstRefToStr, pathPtrToStr) is expecting an argument of a
# different type (see li_std_filesystem.i). Typemaps should be in place to
# convert this pathlib.Path into the expected argument type.
#
check(pathToStr(path) == "foo")
check(pathConstRefToStr(path) == "foo")
check(pathPtrToStr(path) == "foo")

#
# Similarly, each of the input typemaps should know what to do
# with a string.
#
check(pathToStr("foo") == "foo")
check(pathConstRefToStr("foo") == "foo")
check(pathPtrToStr("foo") == "foo")

#
# Similarly, each of the input typemaps should know what to do
# with a std::filesystem::path instance.
#
check(pathToStr(pathPtr) == "foo")
check(pathConstRefToStr(pathPtr) == "foo")
check(pathPtrToStr(pathPtr) == "foo")

specialPath = pathlib.Path("/家/屋")
roundTriped = roundTrip(specialPath)
check(specialPath == roundTriped)
