#!/usr/bin/env ruby

require 'swig_assert'

require 'cpp11_std_unique_ptr'

def gc_check(expected_count)
#  GC.start(full_mark: true, immediate_sweep: true)
  GC.start
# GC is not reliably run, skip check
#  swig_assert_equal_simple(expected_count, Cpp11_std_unique_ptr::Klass::getTotal_count())
end

def checkCount(expected_count)
    actual_count = Cpp11_std_unique_ptr::Klass.getTotal_count()
    if (actual_count != expected_count)
        raise RuntimeError, "Counts incorrect, expected:" + expected_count + " actual:" + actual_count
    end
end

# Test raw pointer handling involving virtual inheritance
kini = Cpp11_std_unique_ptr::KlassInheritance.new("KlassInheritanceInput")
checkCount(1)
s = Cpp11_std_unique_ptr.useKlassRawPtr(kini)
if (s != "KlassInheritanceInput")
    raise RuntimeError, "Incorrect string: " + s
end
# kini = nil
Cpp11_std_unique_ptr.takeKlassUniquePtr(kini) # Ensure object is deleted (can't rely on GC)
checkCount(0)


# unique_ptr as input
kin = Cpp11_std_unique_ptr::Klass.new("KlassInput")
checkCount(1)
s = Cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
if (s != "KlassInput")
    raise RuntimeError, "Incorrect string: " + s
end
exception_thrown = false
begin
    Cpp11_std_unique_ptr.is_nullptr(kin)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
kin = nil
checkCount(0)

kin = Cpp11_std_unique_ptr::Klass.new("KlassInput")
checkCount(1)
s = Cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
if (s != "KlassInput")
    raise RuntimeError, "Incorrect string: " + s
end
exception_thrown = false
begin
    Cpp11_std_unique_ptr.is_nullptr(kin)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
exception_thrown = false
begin
    Cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
rescue RuntimeError => e
    # puts e.message
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "double usage of takeKlassUniquePtr should have been an error"
end
kin = nil
checkCount(0)

kin = Cpp11_std_unique_ptr::Klass.new("KlassInput")
exception_thrown = false
notowned = Cpp11_std_unique_ptr::get_not_owned_ptr(kin)
begin
    Cpp11_std_unique_ptr::takeKlassUniquePtr(notowned)
rescue RuntimeError => e
    if (!e.to_s.include? "cannot release ownership as memory is not owned")
      raise RuntimeError, "incorrect exception message"
    end
    exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown 'Cannot release ownership as memory is not owned' error"
end
checkCount(1)
Cpp11_std_unique_ptr.takeKlassUniquePtr(kin) # Ensure object is deleted (can't rely on GC)
checkCount(0)

kini = Cpp11_std_unique_ptr::KlassInheritance.new("KlassInheritanceInput")
checkCount(1)
s = Cpp11_std_unique_ptr.takeKlassUniquePtr(kini)
checkCount(0)
if (s != "KlassInheritanceInput")
    raise RuntimeError, "Incorrect string: " + s
end
exception_thrown = false
begin
    Cpp11_std_unique_ptr.is_nullptr(kini)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
kini = nil
checkCount(0)

Cpp11_std_unique_ptr::takeKlassUniquePtr(nil)
Cpp11_std_unique_ptr::takeKlassUniquePtr(Cpp11_std_unique_ptr::make_null())
checkCount(0)

# overloaded parameters
if (Cpp11_std_unique_ptr::overloadTest() != 0)
  raise RuntimeError, "overloadTest failed"
end
if (Cpp11_std_unique_ptr::overloadTest(nil) != 1)
  raise RuntimeError, "overloadTest failed"
end
if (Cpp11_std_unique_ptr::overloadTest(Cpp11_std_unique_ptr::Klass.new("over")) != 1)
  raise RuntimeError, "overloadTest failed"
end
checkCount(0);


# unique_ptr as output
k1 = Cpp11_std_unique_ptr::makeKlassUniquePtr("first")
k2 = Cpp11_std_unique_ptr::makeKlassUniquePtr("second")
swig_assert_equal_simple(2, Cpp11_std_unique_ptr::Klass::getTotal_count())

gc_check(2)
k1 = nil
gc_check(1)

swig_assert_equal_simple(k2.getLabel(), "second")
gc_check(1)

k2 = nil
gc_check(0)

swig_assert_equal_simple(Cpp11_std_unique_ptr::makeNullUniquePtr(), nil)
