require("li_std_auto_ptr")
catch_undef_globs() -- catch "undefined" global variables

function checkCount(expected_count)
  -- call gc to make unused objects are collected
  collectgarbage()
  actual_count = li_std_auto_ptr.Klass.getTotal_count()
  assert(actual_count == expected_count, "Counts incorrect, expected:"..expected_count.." actual:"..actual_count)
end

--Test raw pointer handling involving virtual inheritance
kini = li_std_auto_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = li_std_auto_ptr.useKlassRawPtr(kini)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
kini = nil
checkCount(0)

-- auto_ptr as input
kin = li_std_auto_ptr.Klass("KlassInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(li_std_auto_ptr.is_nullptr(kin), "is_nullptr failed")
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = li_std_auto_ptr.Klass("KlassInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kin)
checkCount(0)
assert(s == "KlassInput", "Incorrect string: "..s)
assert(li_std_auto_ptr.is_nullptr(kin), "is_nullptr failed")
s, msg = pcall(function() li_std_auto_ptr.takeKlassAutoPtr(kin) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassAutoPtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = li_std_auto_ptr.Klass("KlassInput")
notowned = li_std_auto_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() li_std_auto_ptr.takeKlassAutoPtr(notowned) end)
assert(not s and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassAutoPtr")
checkCount(1)
kin = nil
checkCount(0)

kini = li_std_auto_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kini)
checkCount(0)
assert(s == "KlassInheritanceInput", "Incorrect string: "..s)
assert(li_std_auto_ptr.is_nullptr(kini), "is_nullptr failed")
kini = nil -- Should not fail, even though already deleted
checkCount(0)

li_std_auto_ptr.takeKlassAutoPtr(nil)
li_std_auto_ptr.takeKlassAutoPtr(li_std_auto_ptr.make_null())
checkCount(0)

-- overloaded parameters
assert(li_std_auto_ptr.overloadTest() == 0, "overloadTest failed")
assert(li_std_auto_ptr.overloadTest(nil) == 1, "overloadTest failed")
assert(li_std_auto_ptr.overloadTest(li_std_auto_ptr.Klass("over")) == 1, "overloadTest failed")
checkCount(0)


-- auto_ptr as output
k1 = li_std_auto_ptr.makeKlassAutoPtr("first")
k2 = li_std_auto_ptr.makeKlassAutoPtr("second")
checkCount(2)

k1 = nil
checkCount(1)

assert(k2:getLabel() == "second", "wrong object label")

k2 = nil
checkCount(0)

assert(li_std_auto_ptr.makeNullAutoPtr() == nil)
