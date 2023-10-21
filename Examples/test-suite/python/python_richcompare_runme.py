import python_richcompare
import sys

def check_unorderable_types(exception):
#    if str(exception).find("unorderable types") == -1:
#        raise RuntimeError("A TypeError 'unorderable types' exception was expected"), None, sys.exc_info()[2]
    pass # Exception message seems to vary from one version of Python to another

base1 = python_richcompare.BaseClass(1)
base2 = python_richcompare.BaseClass(2)
base3 = python_richcompare.BaseClass(3)
a1 = python_richcompare.SubClassA(1)
a2 = python_richcompare.SubClassA(2)
a3 = python_richcompare.SubClassA(3)
b1 = python_richcompare.SubClassB(1)
b2 = python_richcompare.SubClassB(2)
b3 = python_richcompare.SubClassB(3)

# Check == and != within a single type
#-------------------------------------------------------------------------

if not (base1 == base1):
    raise RuntimeError("Object not == to itself")

if not (base1 == python_richcompare.BaseClass(1)):
    raise RuntimeError("Object not == to an equivalent object")

if (base1 == base2):
    raise RuntimeError(
        "Comparing non-equivalent objects of the same type, == returned True")

if (base1 != base1):
    raise RuntimeError("Object is != itself")

if (base1 != python_richcompare.BaseClass(1)):
    raise RuntimeError("Object is != an equivalent object")

if not (base1 != base2):
    raise RuntimeError(
        "Comparing non-equivalent objects of the same type, != returned False")


# Check redefined operator== in SubClassA
#-------------------------------------------------------------------------

if (a2 == base2):
    raise RuntimeError("Redefined operator== in SubClassA failed")

if (a2 == b2):
    raise RuntimeError("Redefined operator== in SubClassA failed")

if not (a1 == a2):
    raise RuntimeError("Redefined operator== in SubClassA failed")

# Check up-casting of subclasses
#-------------------------------------------------------------------------

if (base2 != a2):
    raise RuntimeError(
        "Comparing equivalent base and subclass instances, != returned True")

if (a2 == base2):
    raise RuntimeError(
        "Comparing non-equivalent base and subclass instances, == returned True")

if (a1 == b1):
    raise RuntimeError(
        "Comparing equivalent instances of different subclasses, == returned True")

if (b1 == a1):
    raise RuntimeError(
        "Comparing equivalent instances of different subclasses, == returned True")

# Check comparison to other objects
#-------------------------------------------------------------------------------
if (base1 == 42) :
    raise RuntimeError("Comparing class to incompatible type, == returned True")
if not (base1 != 42) :
    raise RuntimeError("Comparing class to incompatible type, != returned False")

if (a1 == 42) :
    raise RuntimeError("Comparing class (with overloaded operator ==) to incompatible type, == returned True")
if not (a1 != 42) :
    raise RuntimeError("Comparing class (with overloaded operator ==) to incompatible type, != returned False")

# Check inequalities
#-------------------------------------------------------------------------

if (a2 > b2):
    raise RuntimeError("operator> failed")

if (a2 < b2):
    raise RuntimeError("operator< failed")

if not (a2 >= b2):
    raise RuntimeError("operator>= failed")

if not (a2 <= b2):
    raise RuntimeError("operator<= failed")

# Check inequalities to other objects
#-------------------------------------------------------------------------------
if sys.version_info[0:2] < (3, 0):
    if (base1 < 42):
        raise RuntimeError("Comparing class to incompatible type, < returned True")
    if (base1 <= 42):
        raise RuntimeError("Comparing class to incompatible type, <= returned True")
    if not (base1 > 42):
        raise RuntimeError("Comparing class to incompatible type, > returned False")
    if not (base1 >= 42):
        raise RuntimeError("Comparing class to incompatible type, >= returned False")
else:
    # Python 3 throws: TypeError: unorderable types
    try:
        res = base1 < 42
        raise RuntimeError("Failed to throw")
    except TypeError as e:
        check_unorderable_types(e)
    try:
        res = base1 <= 42
        raise RuntimeError("Failed to throw")
    except TypeError as e:
        check_unorderable_types(e)
    try:
        res = base1 > 42
        raise RuntimeError("Failed to throw")
    except TypeError as e:
        check_unorderable_types(e)
    try:
        res = base1 >= 42
        raise RuntimeError("Failed to throw")
    except TypeError as e:
        check_unorderable_types(e)

# Check inequalities used for ordering
#-------------------------------------------------------------------------

x = sorted([a2, a3, a1])

if not (x[0] is a1):
    raise RuntimeError("Ordering failed")

if not (x[1] is a2):
    raise RuntimeError("Ordering failed")

if not (x[2] is a3):
    raise RuntimeError("Ordering failed")

x = sorted([base2, a3, b1])

if not (x[0] is b1):
    raise RuntimeError("Ordering failed")

if not (x[1] is base2):
    raise RuntimeError("Ordering failed")

if not (x[2] is a3):
    raise RuntimeError("Ordering failed")


# Test custom exceptions can still be thrown in operators which use %pythonmaybecall
et0 = python_richcompare.ExceptionThrower(0)
et1 = python_richcompare.ExceptionThrower(1)
et2 = python_richcompare.ExceptionThrower(2)

if not(et1 < et2):
    raise RuntimeError("ExceptionThrower (a) failed")

if et2 < et1:
    raise RuntimeError("ExceptionThrower (b) failed")

try:
    x = et2 < et0
    raise RuntimeError("ExceptionThrower failed to throw ValueError (A)")
except ValueError:
    pass

try:
    x = et0 < et2
    raise RuntimeError("ExceptionThrower failed to throw ValueError (B)")
except ValueError:
    pass

if sys.version_info[0:2] >= (3, 0):
    try:
        x = et2 < 99
        raise RuntimeError("ExceptionThrower (d) failed")
    except TypeError:
        pass

    try:
        x = 99 < et2
        raise RuntimeError("ExceptionThrower (e) failed")
    except TypeError:
        pass

    try:
        x = et0 < 99
        raise RuntimeError("ExceptionThrower (f) failed")
    except TypeError:
        pass

    try:
        x = 99 < et0
        raise RuntimeError("ExceptionThrower (g) failed")
    except TypeError:
        pass


# Overloaded operators and custom exceptions
c0 = python_richcompare.SubClassCThrower(0)
c1 = python_richcompare.SubClassCThrower(1)
c1b = python_richcompare.SubClassCThrower(1)
c2 = python_richcompare.SubClassCThrower(2)

if c1 == c2:
    raise RuntimeError("SubClassCThrower failed (a)")

if not(c1 == c1b):
    raise RuntimeError("SubClassCThrower failed (b)")

if c0 == 99:
    raise RuntimeError("SubClassCThrower failed (c)")

if 99 == c0:
    raise RuntimeError("SubClassCThrower failed (d)")

try:
    x = c0 == c1
    raise RuntimeError("SubClassCThrower failed to throw (A)")
except ValueError:
    pass

try:
    x = c1 == c0
    raise RuntimeError("SubClassCThrower failed to throw (B)")
except ValueError:
    pass
