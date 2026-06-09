local v=require("cpp11_assign_delete")

local mv = v.MemberVars()
local mav = v.MemberArrayVars()

-- (1) Test directly non-assignable member variables
-- These will only have getters
local a1 = mv.MemberPublic
local a2 = mv.MemberProtected
local a3 = mv.MemberPrivate

local ma1 = mav.ArrayMemberPublic
local ma2 = mav.ArrayMemberProtected
local ma3 = mav.ArrayMemberPrivate

-- (2) Test indirectly non-assignable member variables via inheritance
local imv = v.InheritedMemberVars()
-- These will only have getters
local a4 = imv.MemberPublicDerived
local a5 = imv.MemberProtectedDerived
local a6 = imv.MemberPrivateDerived

local sa4 = v.InheritedMemberVars.StaticMemberPublicDerived
local sa5 = v.InheritedMemberVars.StaticMemberProtectedDerived
local sa6 = v.InheritedMemberVars.StaticMemberPrivateDerived

local ga4 = v.GlobalPublicDerived
local ga5 = v.GlobalProtectedDerived
local ga6 = v.GlobalPrivateDerived

-- These will have getters and setters
local a7 = imv.MemberPublicDerivedSettable
imv.MemberPublicDerivedSettable = a7
local a8 = imv.MemberProtectedDerivedSettable
imv.MemberProtectedDerivedSettable = a8
local a9 = imv.MemberPrivateDerivedSettable
imv.MemberPrivateDerivedSettable = a9

local sa7 = v.InheritedMemberVars.StaticMemberPublicDerivedSettable
v.InheritedMemberVars.StaticMemberPublicDerivedSettable = sa7
local sa8 = v.InheritedMemberVars.StaticMemberProtectedDerivedSettable
v.InheritedMemberVars.StaticMemberProtectedDerivedSettable = sa8
local sa9 = v.InheritedMemberVars.StaticMemberPrivateDerivedSettable
v.InheritedMemberVars.StaticMemberPrivateDerivedSettable = sa9

local ga7 = v.GlobalPublicDerivedSettable
v.GlobalPublicDerivedSettable = ga7
local ga8 = v.GlobalProtectedDerivedSettable
v.GlobalProtectedDerivedSettable = ga8
local ga9 = v.GlobalPrivateDerivedSettable
v.GlobalPrivateDerivedSettable = ga9

-- (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
local m = v.MembersMemberVars()

-- These will only have getters
local mpv1 = m.MemberPublic
local mpv2 = m.MemberProtected
local mpv3 = m.MemberPrivate

local smpv1 = v.StaticMembersMemberVars.StaticMemberPublic
local smpv2 = v.StaticMembersMemberVars.StaticMemberProtected
local smpv3 = v.StaticMembersMemberVars.StaticMemberPrivate

local gmpv1 = v.GlobalMemberPublic
local gmpv2 = v.GlobalMemberProtected
local gmpv3 = v.GlobalMemberPrivate

-- Setters and getters available
local smmvh = v.StaticMembersMemberVarsHolder()
local member = smmvh.Member
smmvh.Member = member

local smmv = v.GlobalStaticMembersMemberVars
v.GlobalStaticMembersMemberVars = smmv

-- (4) Test indirectly non-assignable member variables via classes that themselves have non-assignable array member variables
m = v.MembersMemberArrayVars()

-- These will only have getters
mpv1 = m.MemberPublic
mpv2 = m.MemberProtected
mpv3 = m.MemberPrivate

smpv1 = v.StaticMembersMemberArrayVars.StaticMemberPublic
smpv2 = v.StaticMembersMemberArrayVars.StaticMemberProtected
smpv3 = v.StaticMembersMemberArrayVars.StaticMemberPrivate

gmpv1 = v.GlobalArrayMemberPublic
gmpv2 = v.GlobalArrayMemberProtected
gmpv3 = v.GlobalArrayMemberPrivate

-- Setters and getters available
smmvh = v.StaticMembersMemberArrayVarsHolder()
member = smmvh.Member
smmvh.Member = member

smmv = v.GlobalStaticMembersMemberArrayVars
v.GlobalStaticMembersMemberArrayVars = smmv

-- (5) Test indirectly non-assignable member variables via classes that themselves have non-assignable reference member variables
m = v.MembersMemberRefVars()

-- These will only have getters
mpv1 = m.MemberPublic
mpv2 = m.MemberProtected
mpv3 = m.MemberPrivate

smpv1 = v.StaticMembersMemberRefVars.StaticMemberPublic
smpv2 = v.StaticMembersMemberRefVars.StaticMemberProtected
smpv3 = v.StaticMembersMemberRefVars.StaticMemberPrivate

gmpv1 = v.GlobalRefMemberPublic
gmpv2 = v.GlobalRefMemberProtected
gmpv3 = v.GlobalRefMemberPrivate

-- Setters and getters available
smmvh = v.StaticMembersMemberRefVarsHolder()
member = smmvh.Member
smmvh.Member = member

smmv = v.GlobalStaticMembersMemberRefVars
v.GlobalStaticMembersMemberRefVars = smmv
