local v=require("cpp11_shared_ptr_crtp_upcast")

local a = v.FloatArray3D()
assert(swig_type(a) == "std::shared_ptr< stir::Array< 3,float > > *")
local d = v.Float3DDiscretisedDensity()
assert(swig_type(d) == "std::shared_ptr< stir::DiscretisedDensity< 3,float > > *")
local p = v.DataProcessor3DFloat()
assert(swig_type(p) == "std::shared_ptr< stir::DataProcessor< stir::DiscretisedDensity< 3,float > > > *")
local r = v.RPChainedDataProcessor3DFloat() -- std::shared_ptr<RegisteredParsingObject<>>
assert(swig_type(r) == "std::shared_ptr< stir::RegisteredParsingObject< stir::ChainedDataProcessor< stir::DiscretisedDensity< 3,float > >,stir::DataProcessor< stir::DiscretisedDensity< 3,float > >,stir::DataProcessor< stir::DiscretisedDensity< 3,float > > > > *|std::shared_ptr< stir::RegisteredParsingObject< stir::ChainedDataProcessor< stir::DiscretisedDensity< 3,float > >,stir::DataProcessor< DiscretisedDensity< 3,float > >,stir::DataProcessor< DiscretisedDensity< 3,float > > > > *")
-- Using the wrong type fails
assert(not pcall(function() v.useobject(a) end))
assert(not pcall(function() v.useobject(d) end))
assert(not pcall(function() v.useobject(p) end))
assert(pcall(function() v.useobject(r) end)) -- using the proper type pass
