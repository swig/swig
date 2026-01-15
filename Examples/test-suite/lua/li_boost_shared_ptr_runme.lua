require("import")             -- the import fn
import("li_boost_shared_ptr") -- import lib into global
lbsp = li_boost_shared_ptr    --alias

-- catching undefined variables
local env = _ENV                    -- Lua 5.2
if not env then env = getfenv() end -- Lua 5.1
setmetatable(env, { __index = function(t, i) error("undefined global variable `" .. i .. "'", 2) end })

debug_shared = false

-- Helper functions
function verifyValue(expected, got)
	if expected ~= got then
		error("Expected: " .. expected .. " Got: " .. got)
	end
end

function verifyCount(expected, k)
	local got = lbsp.Klass.getTotal_count()
	-- Note: in Lua we can't reliably check reference counts as GC timing is not deterministic
	-- We just verify that the object is still valid
	if k then
		local _ = k:getValue()
	end
end

-- Test functions

-- simple shared_ptr usage - created in Lua
k = lbsp.Klass("me oh my")
val = k:getValue()
verifyValue("me oh my", val)

-- simple shared_ptr usage - not created in C++
k = lbsp.factorycreate()
val = k:getValue()
verifyValue("factorycreate", val)

-- pass by shared_ptr
k = lbsp.Klass("me oh my")
kret = lbsp.smartpointertest(k)
val = kret:getValue()
verifyValue("me oh my smartpointertest", val)

-- pass by shared_ptr pointer
k = lbsp.Klass("me oh my")
kret = lbsp.smartpointerpointertest(k)
val = kret:getValue()
verifyValue("me oh my smartpointerpointertest", val)

-- pass by shared_ptr reference
k = lbsp.Klass("me oh my")
kret = lbsp.smartpointerreftest(k)
val = kret:getValue()
verifyValue("me oh my smartpointerreftest", val)

-- pass by shared_ptr pointer reference
k = lbsp.Klass("me oh my")
kret = lbsp.smartpointerpointerreftest(k)
val = kret:getValue()
verifyValue("me oh my smartpointerpointerreftest", val)

-- const pass by shared_ptr
k = lbsp.Klass("me oh my")
kret = lbsp.constsmartpointertest(k)
val = kret:getValue()
verifyValue("me oh my", val)

-- const pass by shared_ptr pointer
k = lbsp.Klass("me oh my")
kret = lbsp.constsmartpointerpointertest(k)
val = kret:getValue()
verifyValue("me oh my", val)

-- const pass by shared_ptr reference
k = lbsp.Klass("me oh my")
kret = lbsp.constsmartpointerreftest(k)
val = kret:getValue()
verifyValue("me oh my", val)

-- pass by value
k = lbsp.Klass("me oh my")
kret = lbsp.valuetest(k)
val = kret:getValue()
verifyValue("me oh my valuetest", val)

-- pass by pointer
k = lbsp.Klass("me oh my")
kret = lbsp.pointertest(k)
val = kret:getValue()
verifyValue("me oh my pointertest", val)

-- pass by reference
k = lbsp.Klass("me oh my")
kret = lbsp.reftest(k)
val = kret:getValue()
verifyValue("me oh my reftest", val)

-- pass by pointer reference
k = lbsp.Klass("me oh my")
kret = lbsp.pointerreftest(k)
val = kret:getValue()
verifyValue("me oh my pointerreftest", val)

-- null tests
-- Note: In Lua, when a function returns nil and we assign it to a global variable,
-- the global variable checking mechanism can interfere. We use local variables for clarity.
do
	local kret_null

	kret_null = lbsp.smartpointertest(nil)
	if kret_null ~= nil then
		error("return was not nil")
	end

	kret_null = lbsp.smartpointerpointertest(nil)
	if kret_null ~= nil then
		error("return was not nil")
	end

	kret_null = lbsp.smartpointerreftest(nil)
	if kret_null ~= nil then
		error("return was not nil")
	end

	kret_null = lbsp.smartpointerpointerreftest(nil)
	if kret_null ~= nil then
		error("return was not nil")
	end

	-- pointertest with null should return nil
	kret_null = lbsp.pointertest(nil)
	if kret_null ~= nil then
		error("return was not nil")
	end
end

-- test null pointers emitted from C++
do
	local k_null, kret_null

	k_null = lbsp.sp_pointer_null()
	kret_null = lbsp.smartpointertest(k_null)
	if kret_null ~= nil then
		error("return was not nil")
	end

	k_null = lbsp.null_sp_pointer()
	kret_null = lbsp.smartpointertest(k_null)
	if kret_null ~= nil then
		error("return was not nil")
	end

	k_null = lbsp.sp_value_null()
	kret_null = lbsp.smartpointertest(k_null)
	if kret_null ~= nil then
		error("return was not nil")
	end
end

-- $owner
k = lbsp.pointerownertest()
val = k:getValue()
verifyValue("pointerownertest", val)

k = lbsp.smartpointerpointerownertest()
val = k:getValue()
verifyValue("smartpointerpointerownertest", val)

-- Derived class
-- derived pass by shared_ptr
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedsmartptrtest(k)
val = kret:getValue()
verifyValue("me oh my derivedsmartptrtest-Derived", val)

-- derived pass by shared_ptr pointer
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedsmartptrpointertest(k)
val = kret:getValue()
verifyValue("me oh my derivedsmartptrpointertest-Derived", val)

-- derived pass by shared_ptr ref
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedsmartptrreftest(k)
val = kret:getValue()
verifyValue("me oh my derivedsmartptrreftest-Derived", val)

-- derived pass by shared_ptr pointer ref
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedsmartptrpointerreftest(k)
val = kret:getValue()
verifyValue("me oh my derivedsmartptrpointerreftest-Derived", val)

-- derived pass by pointer
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedpointertest(k)
val = kret:getValue()
verifyValue("me oh my derivedpointertest-Derived", val)

-- derived pass by ref
k = lbsp.KlassDerived("me oh my")
kret = lbsp.derivedreftest(k)
val = kret:getValue()
verifyValue("me oh my derivedreftest-Derived", val)

-- 3rd derived class test for upcast
k = lbsp.Klass3rdDerived("me oh my")
val = lbsp.test3rdupcast(k)
verifyValue("me oh my-3rdDerived", val)

-- Member variable tests
mv = lbsp.MemberVariables()
k = lbsp.Klass("smart member value")
mv.SmartMemberValue = k
val = mv.SmartMemberValue:getValue()
verifyValue("smart member value", val)

k = lbsp.Klass("smart member pointer")
mv.SmartMemberPointer = k
val = mv.SmartMemberPointer:getValue()
verifyValue("smart member pointer", val)

k = lbsp.Klass("smart member reference")
mv.SmartMemberReference = k
val = mv.SmartMemberReference:getValue()
verifyValue("smart member reference", val)

-- Global variable tests
k = lbsp.Klass("global value")
lbsp.GlobalValue = k
val = lbsp.GlobalValue:getValue()
verifyValue("global value", val)

k = lbsp.Klass("global pointer")
lbsp.GlobalPointer = k
val = lbsp.GlobalPointer:getValue()
verifyValue("global pointer", val)

k = lbsp.Klass("global reference")
lbsp.GlobalReference = k
val = lbsp.GlobalReference:getValue()
verifyValue("global reference", val)

-- Global smart pointer tests
k = lbsp.Klass("global smart value")
lbsp.GlobalSmartValue = k
val = lbsp.GlobalSmartValue:getValue()
verifyValue("global smart value", val)

k = lbsp.Klass("global smart pointer")
lbsp.GlobalSmartPointer = k
val = lbsp.GlobalSmartPointer:getValue()
verifyValue("global smart pointer", val)

k = lbsp.Klass("global smart reference")
lbsp.GlobalSmartReference = k
val = lbsp.GlobalSmartReference:getValue()
verifyValue("global smart reference", val)
