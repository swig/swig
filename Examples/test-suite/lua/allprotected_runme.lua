local v=require("allprotected")

local klass = v.Klass("allprotected_klass")
assert(klass:getName() == "allprotected_klass", "klass.getName()")

local publicBase = v.PublicBase("allprotected_PubBase")
assert(publicBase:virtualMethod() == "PublicBase", "publicBase.virtualMethod()")

local class = publicBase:instanceMethod(klass)
assert(class:getName() == "allprotected_klass", "publicBase.instanceMethod(klass).getName()")

class = publicBase:instanceOverloaded(klass)
assert(class:getName() == "allprotected_klass", "publicBase.instanceOverloaded(klass).getName()")

class = v.PublicBase.staticMethod(klass)
assert(class:getName() == "allprotected_klass", "PublicBase.staticMethod(klass).getName()")

class = v.PublicBase.staticOverloaded(klass)
assert(class:getName() == "allprotected_klass", "PublicBase.staticOverloaded(klass).getName()")

class = v.PublicBase.staticOverloaded(klass, "allprotected_klass3")
assert(class:getName() == "allprotected_klass3", "PublicBase.staticOverloaded(klass, \"allprotected_klass3\").getName()")

assert(v.PublicBase.EnumVal1 == 0, "PublicBase.EnumVal1")
assert(v.PublicBase.EnumVal2 == 1, "PublicBase.EnumVal2")

v.PublicBase.instanceMemberVariable = 12
assert(v.PublicBase.instanceMemberVariable == 12, "PublicBase.instanceMemberVariable")

assert(v.PublicBase.staticConstMemberVariable == 20, "PublicBase.staticConstMemberVariable")
assert(v.PublicBase.staticMemberVariable == 10, "PublicBase.staticMemberVariable")

publicBase.stringMember = "dummy"
assert(publicBase.stringMember == "dummy", "publicBase.stringMember")

assert(publicBase.anEnum == v.PublicBase.EnumVal1, "publicBase.anEnum == EnumVal1");
publicBase.anEnum = v.PublicBase.EnumVal2
assert(publicBase.anEnum == v.PublicBase.EnumVal2, "publicBase.anEnum == EnumVal2");

local procBase = v.ProtectedBase("allprotected_ProcBase")
assert(procBase ~= nil)
assert(procBase:virtualMethod() == "ProtectedBase", "procBase.virtualMethod()")
assert(procBase.anEnum == v.ProtectedBase.EnumVal1, "procBase.anEnum")
