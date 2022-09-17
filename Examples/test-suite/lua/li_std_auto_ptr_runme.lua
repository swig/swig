require("import")	-- the import fn
import("li_std_auto_ptr")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})


function checkCount(expected_count)
  -- call gc to make unused objects are collected
  collectgarbage()
  actual_count = li_std_auto_ptr.Klass.getTotal_count()
  if not (actual_count == expected_count) then
    error("Counts incorrect, expected:"..expected_count.." actual:"..actual_count)
  end
end

--Test raw pointer handling involving virtual inheritance
kini = li_std_auto_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = li_std_auto_ptr.useKlassRawPtr(kini)
if not (s == "KlassInheritanceInput") then
  error("Incorrect string: "..s)
end
kini = nil
checkCount(0)

-- auto_ptr as input
kin = li_std_auto_ptr.Klass("KlassInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kin)
checkCount(0)
if not (s == "KlassInput") then
  error("Incorrect string: "..s)
end
if not (li_std_auto_ptr.is_nullptr(kin)) then
  error("is_nullptr failed")
end
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = li_std_auto_ptr.Klass("KlassInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kin)
checkCount(0)
if not (s == "KlassInput") then
  error("Incorrect string: "..s)
end
if not (li_std_auto_ptr.is_nullptr(kin)) then
  error("is_nullptr failed")
end
s, msg = pcall(function() li_std_auto_ptr.takeKlassAutoPtr(kin) end)
assert(s == false and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassAutoPtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = li_std_auto_ptr.Klass("KlassInput")
notowned = li_std_auto_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() li_std_auto_ptr.takeKlassAutoPtr(notowned) end)
assert(s == false and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassAutoPtr")
checkCount(1)
kin = nil
checkCount(0)

kini = li_std_auto_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = li_std_auto_ptr.takeKlassAutoPtr(kini)
checkCount(0)
if not (s == "KlassInheritanceInput") then
  error("Incorrect string: "..s)
end
if not (li_std_auto_ptr.is_nullptr(kini)) then
  error("is_nullptr failed")
end
kini = nil -- Should not fail, even though already deleted
checkCount(0)

li_std_auto_ptr.takeKlassAutoPtr(nil);
li_std_auto_ptr.takeKlassAutoPtr(li_std_auto_ptr.make_null());
checkCount(0);

-- overloaded parameters
if not (li_std_auto_ptr.overloadTest() == 0) then
  error("overloadTest failed")
end
if not (li_std_auto_ptr.overloadTest(nil) == 1) then
  error("overloadTest failed")
end
if not (li_std_auto_ptr.overloadTest(li_std_auto_ptr.Klass("over")) == 1) then
  error("overloadTest failed")
end
checkCount(0)


-- auto_ptr as output
k1 = li_std_auto_ptr.makeKlassAutoPtr("first")
k2 = li_std_auto_ptr.makeKlassAutoPtr("second")
checkCount(2)

k1 = nil
checkCount(1)

if not (k2:getLabel() == "second") then
  error("wrong object label")
end

k2 = nil
checkCount(0)

assert(li_std_auto_ptr.makeNullAutoPtr() == nil)
