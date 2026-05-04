local v=require("cpp11_ref_qualifiers_typemaps")

local tm = v.TypemapsNamedParms();
assert(tm:fff(v.FF1_MFP) == 2)
assert(tm:ccc(v.CC4_MFP) == 5)
assert(tm:ggg(v.GG7_MFP) == 8)
assert(tm:hhh(v.HH10_MFP) == 11)

tm = v.TypemapsUnnamedParms();
assert(tm:fff(v.FF1_MFP) == 3)
assert(tm:ccc(v.CC4_MFP) == 6)
assert(tm:ggg(v.GG7_MFP) == 9)
assert(tm:hhh(v.HH10_MFP) == 12)
