from cpp11_std_unique_ptr import *

def checkCount(expected_count):
    actual_count = Klass.getTotal_count()
    if (actual_count != expected_count):
        raise RuntimeError("Counts incorrect, expected: {} actual:{}".format(expected_count, actual_count))

# Test raw pointer handling involving virtual inheritance
kini = KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = useKlassRawPtr(kini)
if s != "KlassInheritanceInput":
    raise RuntimeError("Incorrect string: " + s)
del kini
checkCount(0)


# #### INPUT BY VALUE ####
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
        raise RuntimeError("incorrect exception message")
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

takeKlassUniquePtr(None)
takeKlassUniquePtr(make_null())
checkCount(0)

# overloaded parameters
if overloadTest() != 0:
  raise RuntimeError("overloadTest failed")
if overloadTest(None) != 1:
  raise RuntimeError("overloadTest failed")
if overloadTest(Klass("over")) != 1:
  raise RuntimeError("overloadTest failed")
checkCount(0)


# #### INPUT BY RVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput")
checkCount(1)
s = moveKlassUniquePtr(kin)
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
s = moveKlassUniquePtr(kin)
checkCount(0)
if kin.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kin):
    raise RuntimeError("is_nullptr failed")
exception_thrown = False
try:
    s = moveKlassUniquePtr(kin)
except RuntimeError as e:
    if "cannot release ownership as memory is not owned" not in str(e):
        raise RuntimeError("incorrect exception message")
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("double usage of moveKlassUniquePtr should have been an error")
del kin # Should not fail, even though already deleted
checkCount(0)

kin = Klass("KlassInput")
exception_thrown = False
notowned = get_not_owned_ptr(kin)
try:
    moveKlassUniquePtr(notowned)
except RuntimeError as e:
    exception_thrown = True
if not exception_thrown:
  raise RuntimeError("Should have thrown 'Cannot release ownership as memory is not owned' error")
checkCount(1)
del kin
checkCount(0)

kini = KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = moveKlassUniquePtr(kini)
checkCount(0)
if kini.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInheritanceInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kini):
    raise RuntimeError("is_nullptr failed")
del kini # Should not fail, even though already deleted
checkCount(0)

moveKlassUniquePtr(None)
moveKlassUniquePtr(make_null())
checkCount(0)

# overloaded parameters
if moveOverloadTest() != 0:
  raise RuntimeError("moveOverloadTest failed")
if moveOverloadTest(None) != 1:
  raise RuntimeError("moveOverloadTest failed")
if moveOverloadTest(Klass("over")) != 1:
  raise RuntimeError("moveOverloadTest failed")
checkCount(0)


# #### INPUT BY NON-CONST LVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput")
checkCount(1)
s = moveRefKlassUniquePtr(kin)
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
s = moveRefKlassUniquePtr(kin)
checkCount(0)
if kin.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kin):
    raise RuntimeError("is_nullptr failed")
exception_thrown = False
try:
    s = moveRefKlassUniquePtr(kin)
except RuntimeError as e:
    if "cannot release ownership as memory is not owned" not in str(e):
        raise RuntimeError("incorrect exception message")
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("double usage of moveRefKlassUniquePtr should have been an error")
del kin # Should not fail, even though already deleted
checkCount(0)

kin = Klass("KlassInput")
exception_thrown = False
notowned = get_not_owned_ptr(kin)
try:
    moveRefKlassUniquePtr(notowned)
except RuntimeError as e:
    exception_thrown = True
if not exception_thrown:
  raise RuntimeError("Should have thrown 'Cannot release ownership as memory is not owned' error")
checkCount(1)
del kin
checkCount(0)

kini = KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = moveRefKlassUniquePtr(kini)
checkCount(0)
if kini.thisown:
    raise RuntimeError("thisown should be false")
if s != "KlassInheritanceInput":
    raise RuntimeError("Incorrect string: " + s)
if not is_nullptr(kini):
    raise RuntimeError("is_nullptr failed")
del kini # Should not fail, even though already deleted
checkCount(0)

moveRefKlassUniquePtr(None)
moveRefKlassUniquePtr(make_null())
checkCount(0)

# overloaded parameters
if moveRefOverloadTest() != 0:
  raise RuntimeError("moveRefOverloadTest failed")
if moveRefOverloadTest(None) != 1:
  raise RuntimeError("moveRefOverloadTest failed")
if moveRefOverloadTest(Klass("over")) != 1:
  raise RuntimeError("moveRefOverloadTest failed")
checkCount(0)


# #### INPUT BY CONST LVALUE REF ####
# unique_ptr as input
kin = Klass("KlassInput")
checkCount(1)
s = useRefKlassUniquePtr(kin)
checkCount(1)
if s != "KlassInput":
    raise RuntimeError("Incorrect string: " + s)
del kin
checkCount(0)

kini = KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = useRefKlassUniquePtr(kini)
checkCount(1)
if s != "KlassInheritanceInput":
    raise RuntimeError("Incorrect string: " + s)
del kini
checkCount(0)

useRefKlassUniquePtr(None)
useRefKlassUniquePtr(make_null())
checkCount(0)

# overloaded parameters
if useRefOverloadTest() != 0:
  raise RuntimeError("useRefOverloadTest failed")
if useRefOverloadTest(None) != 1:
  raise RuntimeError("useRefOverloadTest failed")
kin = Klass("over")
if useRefOverloadTest(kin) != 1:
  raise RuntimeError("useRefOverloadTest failed")
checkCount(1)
del kin
checkCount(0)


# unique_ptr as output
k1 = makeKlassUniquePtr("first")
k2 = makeKlassUniquePtr("second")
checkCount(2)

del k1
checkCount(1)

if k2.getLabel() != "second":
    raise "wrong object label"

del k2
checkCount(0)

if (makeNullUniquePtr() != None):
  raise RuntimeError("null failure")

# unique_ptr as output (rvalue ref)
k1 = makeRVRKlassUniquePtr("first")
if k1.getLabel() != "first":
    raise "wrong object label"
if (makeRVRKlassUniquePtr(None) != None):
  raise RuntimeError("null failure")

# unique_ptr as output (lvalue ref)
k1 = makeRefKlassUniquePtr("lvalueref")
if k1.getLabel() != "lvalueref":
    raise "wrong object label"
if (makeRVRKlassUniquePtr(None) != None):
  raise RuntimeError("null failure")
