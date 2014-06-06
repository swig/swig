exec("swigtest.start", -1);

// Class Klass 
try
  klass = new_Klass("allprotected_klass");
catch
  swigtesterror();
end

if Klass_getName(klass) <> "allprotected_klass" then swigtesterror(); end

// Class PublicBase
try
  publicBase = new_PublicBase("allprotected_publicbase");
catch
  swigtesterror();
end

if PublicBase_virtualMethod(publicBase) <> "PublicBase" then swigtesterror(); end
if Klass_getName(PublicBase_instanceMethod(publicBase, klass)) <> "allprotected_klass" then swigtesterror(); end
if Klass_getName(PublicBase_instanceOverloaded(publicBase, klass)) <> "allprotected_klass" then swigtesterror(); end
if Klass_getName(PublicBase_instanceOverloaded(publicBase, klass, "allprotected_klass2")) <> "allprotected_klass2" then swigtesterror(); end
if Klass_getName(PublicBase_staticMethod(klass)) <> "allprotected_klass" then swigtesterror(); end
if Klass_getName(PublicBase_staticOverloaded(klass)) <> "allprotected_klass" then swigtesterror(); end
if Klass_getName(PublicBase_staticOverloaded(klass, "allprotected_klass3")) <> "allprotected_klass3" then swigtesterror(); end
if PublicBase_EnumVal1_get() <> 0 then swigtesterror(); end
if PublicBase_EnumVal2_get() <> 1 then swigtesterror(); end


// TODO does not work (wrong ENUM mapping?)
//PublicBase_anEnum_get(publicBase)
//PublicBase_anEnum_set(publicBase, ???)

// TODO Can not be tested in Sciolab because too long identifiers
//PublicBase_instanceMemberVariabl
//PublicBase_instanceMemberVariabl
//PublicBase_staticConstMemberVari
//PublicBase_staticMemberVariable_
//PublicBase_staticMemberVariable_
//PublicBase_stringMember_get
//PublicBase_stringMember_set

// Class ProtectedBase
try
// Constructor is propected and must not be defined here
  protectedBase = new_ProtectedBase("allprotected_protectedbase");
  swigtesterror();
catch
end

if ProtectedBase_EnumVal1_get() <> 0 then swigtesterror(); end
if ProtectedBase_EnumVal2_get() <> 1 then swigtesterror(); end

try
  delete_Klass(klass);
catch
  swigtesterror();
end
try
  delete_PublicBase(publicBase);
catch
  swigtesterror();
end

exec("swigtest.quit", -1);
