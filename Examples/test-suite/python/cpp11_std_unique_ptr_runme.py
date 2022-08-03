from cpp11_std_unique_ptr import *

def checkCount(expected_count):
    actual_count = Klass.getTotal_count()
    if (actual_count != expected_count):
        raise RuntimeError("Counts incorrect, expected:" + expected_count + " actual:" + actual_count)

# unique_ptr as input
kin = Klass("KlassInput")
checkCount(1)
s = takeKlassUniquePtr(kin)
checkCount(0)
if kin.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kin):
    raise RuntimeError("is_nullptr failed")
del kin # Should not fail, even though already deleted
checkCount(0)

kin = Klass("KlassInput")
checkCount(1)
s = takeKlassUniquePtr(kin)
checkCount(0)
if kin.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kin):
    raise RuntimeError("is_nullptr failed")
exception_thrown = False
try:
    s = takeKlassUniquePtr(kin)
except RuntimeError as e:
    if "cannot release ownership as memory is not owned" not in str(e):
        raise RuntimeError("incorrect exception message");
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("double usage of takeKlassUniquePtr should have been an error")
del kin # Should not fail, even though already deleted
checkCount(0)

kin = Klass("KlassInput")
exception_thrown = False
notowned = get_not_owned_ptr(kin)
try:
    takeKlassUniquePtr(notowned)
except RuntimeError as e:
    exception_thrown = True
if not exception_thrown:
  raise RuntimeError("Should have thrown 'Cannot release ownership as memory is not owned' error")
checkCount(1)
del kin
checkCount(0)

kini = KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = takeKlassUniquePtr(kini)
checkCount(0)
if kini.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInheritanceInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kini):
    raise RuntimeError("is_nullptr failed")
del kini # Should not fail, even though already deleted
checkCount(0)

# unique_ptr as output
k1 = makeKlassUniquePtr("first")
k2 = makeKlassUniquePtr("second")
if Klass.getTotal_count() != 2:
    raise "number of objects should be 2"

del k1
if Klass.getTotal_count() != 1:
    raise "number of objects should be 1"

if k2.getLabel() != "second":
    raise "wrong object label"

del k2
if Klass.getTotal_count() != 0:
    raise "no objects should be left"
