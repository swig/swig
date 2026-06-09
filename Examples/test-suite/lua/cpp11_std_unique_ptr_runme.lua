require("cpp11_std_unique_ptr")
catch_undef_globs() -- catch "undefined" global variables

function checkCount(expected_count)
  -- call gc to make unused objects are collected
  collectgarbage()
  actual_count = cpp11_std_unique_ptr.Klass.getTotal_count()
  assert(actual_count == expected_count, "Counts incorrect, expected:"..expected_count.." actual:"..actual_count)
end

--Test raw pointer handling involving virtual inheritance
kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.useKlassRawPtr(kini)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
kini = nil
checkCount(0)

--- ---- INPUT BY VALUE ---
-- unique_ptr as input
kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
s, msg = pcall(function() cpp11_std_unique_ptr.takeKlassUniquePtr(kin) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassUniquePtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() cpp11_std_unique_ptr.takeKlassUniquePtr(notowned) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassUniquePtr")
checkCount(1)
kin = nil
checkCount(0)

kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kini)
checkCount(0)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kini), "is_nullptr failed")
kini = nil -- Should not fail, even though already deleted
checkCount(0)

cpp11_std_unique_ptr.takeKlassUniquePtr(nil)
cpp11_std_unique_ptr.takeKlassUniquePtr(cpp11_std_unique_ptr.make_null())
checkCount(0)

-- overloaded parameters
assert(cpp11_std_unique_ptr.overloadTest() == 0, "overloadTest failed")
assert(cpp11_std_unique_ptr.overloadTest(nil) == 1, "overloadTest failed")
assert(cpp11_std_unique_ptr.overloadTest(cpp11_std_unique_ptr.Klass("over")) == 1, "overloadTest failed")
checkCount(0)


--- ---- INPUT BY RVALUE REF ---
-- unique_ptr as input
kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
s, msg = pcall(function() cpp11_std_unique_ptr.moveKlassUniquePtr(kin) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in moveKlassUniquePtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() cpp11_std_unique_ptr.moveKlassUniquePtr(notowned) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in moveKlassUniquePtr")
checkCount(1)
kin = nil
checkCount(0)

kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveKlassUniquePtr(kini)
checkCount(0)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kini), "is_nullptr failed")
kini = nil -- Should not fail, even though already deleted
checkCount(0)

cpp11_std_unique_ptr.moveKlassUniquePtr(nil)
cpp11_std_unique_ptr.moveKlassUniquePtr(cpp11_std_unique_ptr.make_null())
checkCount(0)

-- overloaded parameters
assert(cpp11_std_unique_ptr.moveOverloadTest() == 0, "moveOverloadTest failed")
assert(cpp11_std_unique_ptr.moveOverloadTest(nil) == 1, "moveOverloadTest failed")
assert(cpp11_std_unique_ptr.moveOverloadTest(cpp11_std_unique_ptr.Klass("over")) == 1, "moveOverloadTest failed")
checkCount(0)


--- ---- INPUT BY NON-CONST LVALUE REF ---
-- unique_ptr as input
kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kin), "is_nullptr failed")
s, msg = pcall(function() cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in moveRefKlassUniquePtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() cpp11_std_unique_ptr.moveRefKlassUniquePtr(notowned) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in moveRefKlassUniquePtr")
checkCount(1)
kin = nil
checkCount(0)

kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kini)
checkCount(0)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
assert(cpp11_std_unique_ptr.is_nullptr(kini), "is_nullptr failed")
kini = nil -- Should not fail, even though already deleted
checkCount(0)

cpp11_std_unique_ptr.moveRefKlassUniquePtr(nil)
cpp11_std_unique_ptr.moveRefKlassUniquePtr(cpp11_std_unique_ptr.make_null())
checkCount(0)

-- overloaded parameters
assert(cpp11_std_unique_ptr.moveRefOverloadTest() == 0, "moveRefOverloadTest failed")
assert(cpp11_std_unique_ptr.moveRefOverloadTest(nil) == 1, "moveRefOverloadTest failed")
assert(cpp11_std_unique_ptr.moveRefOverloadTest(cpp11_std_unique_ptr.Klass("over")) == 1, "moveRefOverloadTest failed")
checkCount(0)


--- ---- INPUT BY CONST LVALUE REF ---
-- unique_ptr as input
kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kin)
checkCount(1)
assert(s == "KlassInput", "Incorrect string: "..s)
kin = nil
checkCount(0)

kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kini)
checkCount(1)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
kini = nil
checkCount(0)

cpp11_std_unique_ptr.useRefKlassUniquePtr(nil)
cpp11_std_unique_ptr.useRefKlassUniquePtr(cpp11_std_unique_ptr.make_null())
checkCount(0)

-- overloaded parameters
assert(cpp11_std_unique_ptr.useRefOverloadTest() == 0, "useRefOverloadTest failed")
assert(cpp11_std_unique_ptr.useRefOverloadTest(nil) == 1, "useRefOverloadTest failed")
kin = cpp11_std_unique_ptr.Klass("over")
assert(cpp11_std_unique_ptr.useRefOverloadTest(kin) == 1, "useRefOverloadTest failed")
checkCount(1)
kin = nil
checkCount(0)


-- unique_ptr as output
k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first")
k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second")
checkCount(2)

k1 = nil
checkCount(1)

assert(k2:getLabel() == "second", "wrong object label")

k2 = nil
checkCount(0)

assert(cpp11_std_unique_ptr.makeNullUniquePtr() == nil)

-- unique_ptr as output (rvalue ref)
k1 = cpp11_std_unique_ptr.makeRVRKlassUniquePtr("first")
assert(k1:getLabel() == "first", "wrong object label")
assert(cpp11_std_unique_ptr.makeRVRKlassUniquePtr(nil) == nil)

-- unique_ptr as output (lvalue ref)
k1 = cpp11_std_unique_ptr.makeRefKlassUniquePtr("lvalueref")
assert(k1:getLabel() == "lvalueref", "wrong object label")
assert(cpp11_std_unique_ptr.makeRefKlassUniquePtr(nil) == nil)
