local v=require("assign_const")

local mv = v.MemberVars()
assert(mv ~= nil)

-- (1) Test directly non-assignable member variables
-- These will only have getters
local a1 = mv.MemberValue
assert(type(a1.ValueMember) == "number")
local a2 = mv.MemberArray
assert(swig_type(a2) == "AssignArray *")
local a3 = mv.MemberPtr
assert(swig_type(a3) == "AssignPtr *")
local a4 = mv.MemberMatrix
assert(swig_type(a4) == "AssignMatrix *")

-- (2) Test indirectly non-assignable member variables via inheritance
local imv = v.InheritedMemberVars()
-- These will only have getters
local aa4 = imv.MemberValueDerived
assert(type(aa4.ValueMember) == "number")
local aa5 = imv.MemberArrayDerived
assert(swig_type(aa5) == "AssignArrayDerived *")
local aa6 = imv.MemberPtrDerived
assert(swig_type(aa6) == "AssignPtrDerived *")
local aa7 = imv.MemberMatrixDerived
assert(swig_type(aa7) == "AssignMatrixDerived *")

local sa4 = v.InheritedMemberVars.StaticMemberValueDerived
assert(type(sa4.ValueMember) == "number")
local sa5 = v.InheritedMemberVars.StaticMemberArrayDerived
assert(swig_type(sa5) == "AssignArrayDerived *")
local sa6 = v.InheritedMemberVars.StaticMemberPtrDerived
assert(swig_type(sa6) == "AssignPtrDerived *")
local sa7 = v.InheritedMemberVars.StaticMemberMatrixDerived
assert(swig_type(sa7) == "AssignMatrixDerived *")

local ga4 = assign_const.GlobalValueDerived
assert(type(ga4.ValueMember) == "number")
local ga5 = assign_const.GlobalArrayDerived
assert(swig_type(ga5) == "AssignArrayDerived *")
local ga6 = assign_const.GlobalPtrDerived
assert(swig_type(ga6) == "AssignPtrDerived *")
local ga7 = assign_const.GlobalMatrixDerived
assert(swig_type(ga7) == "AssignMatrixDerived *")

-- These will have getters and setters
local a7 = imv.MemberValueDerivedSettable
assert(type(a7.ValueMember) == "number")
imv.MemberValueDerivedSettable = a7
local a8 = imv.MemberArrayDerivedSettable
assert(swig_type(a8) == "AssignArrayDerivedSettable *")
imv.MemberArrayDerivedSettable = a8
local a9 = imv.MemberPtrDerivedSettable
assert(swig_type(a9) == "AssignPtrDerivedSettable *")
imv.MemberPtrDerivedSettable = a9
local a10 = imv.MemberMatrixDerivedSettable
assert(swig_type(a10) == "AssignMatrixDerivedSettable *")
imv.MemberMatrixDerivedSettable = a10

local saa7 = v.InheritedMemberVars.StaticMemberValueDerivedSettable
assert(type(saa7.ValueMember) == "number")
v.InheritedMemberVars.StaticMemberValueDerivedSettable = saa7
local saa8 = v.InheritedMemberVars.StaticMemberArrayDerivedSettable
assert(swig_type(saa8) == "AssignArrayDerivedSettable *")
v.InheritedMemberVars.StaticMemberArrayDerivedSettable = saa8
local saa9 = v.InheritedMemberVars.StaticMemberPtrDerivedSettable
assert(swig_type(saa9) == "AssignPtrDerivedSettable *")
v.InheritedMemberVars.StaticMemberPtrDerivedSettable = saa9
local saa10 = v.InheritedMemberVars.StaticMemberMatrixDerivedSettable
assert(swig_type(saa10) == "AssignMatrixDerivedSettable *")
v.InheritedMemberVars.StaticMemberMatrixDerivedSettable = saa10

local gaa7 = assign_const.GlobalValueDerivedSettable
assign_const.GlobalValueDerivedSettable = gaa7
local gaa8 = assign_const.GlobalArrayDerivedSettable
assign_const.GlobalArrayDerivedSettable = gaa8
local gaa9 = assign_const.GlobalPtrDerivedSettable
assign_const.GlobalPtrDerivedSettable = gaa9
local gaa10 = assign_const.GlobalMatrixDerivedSettable
assign_const.GlobalMatrixDerivedSettable = gaa10

-- (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
local m = v.MembersMemberVars()

-- These will only have getters
local mpv1 = m.MemberValue
local mpv2 = m.MemberArray
local mpv3 = m.MemberPtr
local mpv4 = m.MemberMatrix

local smpv1 = v.StaticMembersMemberVars.StaticMemberValue
local smpv2 = v.StaticMembersMemberVars.StaticMemberArray
local smpv3 = v.StaticMembersMemberVars.StaticMemberPtr
local smpv4 = v.StaticMembersMemberVars.StaticMemberMatrix

local gmpv1 = assign_const.GlobalMemberValue
local gmpv2 = assign_const.GlobalMemberArray
local gmpv3 = assign_const.GlobalMemberPtr
local gmpv4 = assign_const.GlobalMemberMatrix

-- Setters and getters available
local smmvh = v.StaticMembersMemberVarsHolder()
local member = smmvh.Member
smmvh.Member = member

local smmv = assign_const.GlobalStaticMembersMemberVars
assign_const.GlobalStaticMembersMemberVars = smmv
