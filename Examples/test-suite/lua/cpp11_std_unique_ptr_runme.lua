require("import")	-- the import fn
import("cpp11_std_unique_ptr")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})


function checkCount(expected_count)
  -- call gc to make unused objects are collected
  collectgarbage()
  actual_count = cpp11_std_unique_ptr.Klass.getTotal_count()
  if not (actual_count == expected_count) then
    error("Counts incorrect, expected:"..expected_count.." actual:"..actual_count)
  end
end

--Test raw pointer handling involving virtual inheritance
kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.useKlassRawPtr(kini)
if not (s == "KlassInheritanceInput") then
  error("Incorrect string: "..s)
end
kini = nil
checkCount(0)

-- unique_ptr as input
kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
if not (s == "KlassInput") then
  error("Incorrect string: "..s)
end
if not (cpp11_std_unique_ptr.is_nullptr(kin)) then
  error("is_nullptr failed")
end
kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin)
checkCount(0)
if not (s == "KlassInput") then
  error("Incorrect string: "..s)
end
if not (cpp11_std_unique_ptr.is_nullptr(kin)) then
  error("is_nullptr failed")
end
s, msg = pcall(function() cpp11_std_unique_ptr.takeKlassUniquePtr(kin) end)
assert(s == false and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassUniquePtr")

kin = nil -- Should not fail, even though already deleted
checkCount(0)

kin = cpp11_std_unique_ptr.Klass("KlassInput")
notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin)
s, msg = pcall(function() cpp11_std_unique_ptr.takeKlassUniquePtr(notowned) end)
assert(s == false and msg == "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' in takeKlassUniquePtr")
checkCount(1)
kin = nil
checkCount(0)

kini = cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput")
checkCount(1)
s = cpp11_std_unique_ptr.takeKlassUniquePtr(kini)
checkCount(0)
if not (s == "KlassInheritanceInput") then
  error("Incorrect string: "..s)
end
if not (cpp11_std_unique_ptr.is_nullptr(kini)) then
  error("is_nullptr failed")
end
kini = nil -- Should not fail, even though already deleted
checkCount(0)

cpp11_std_unique_ptr.takeKlassUniquePtr(nil);
cpp11_std_unique_ptr.takeKlassUniquePtr(cpp11_std_unique_ptr.make_null());
checkCount(0);

-- overloaded parameters
if not (cpp11_std_unique_ptr.overloadTest() == 0) then
  error("overloadTest failed")
end
if not (cpp11_std_unique_ptr.overloadTest(nil) == 1) then
  error("overloadTest failed")
end
if not (cpp11_std_unique_ptr.overloadTest(cpp11_std_unique_ptr.Klass("over")) == 1) then
  error("overloadTest failed")
end
checkCount(0)


-- unique_ptr as output
k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first")
k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second")
checkCount(2)

k1 = nil
checkCount(1)

if not (k2:getLabel() == "second") then
  error("wrong object label")
end

k2 = nil
checkCount(0)

assert(cpp11_std_unique_ptr.makeNullUniquePtr() == nil)
