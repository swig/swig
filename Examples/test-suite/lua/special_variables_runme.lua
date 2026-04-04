local v=require("special_variables")

assert(v.ExceptionVars(1, 2) == "result = Space::exceptionvars(arg1,arg2);  Space::exceptionvars  ExceptionVars   _wrap_ExceptionVars  ")
assert(v.overloadedmethod() ==   "result = Space::overloadedmethod();  Space::overloadedmethod  overloadedmethod  __SWIG_1 _wrap_overloadedmethod__SWIG_1  ")
assert(v.overloadedmethod(10) == "result = Space::overloadedmethod(arg1);  Space::overloadedmethod  overloadedmethod  __SWIG_0 _wrap_overloadedmethod__SWIG_0  ")

local a = v.ABC(0, 0)
assert(v.declaration == "SpaceNamespace::ABC::ABC(int,double) SpaceNamespace::ABC::ABC(int,double)")
local a = v.ABC()
assert(v.declaration == "SpaceNamespace::ABC::ABC() SpaceNamespace::ABC::ABC()")
a:instancemethod(1)
assert(v.declaration == "short * SpaceNamespace::ABC::instancemethod(int) SpaceNamespace::ABC::instancemethod(int)")
a:instancemethod(1, false)
assert(v.declaration == "short * SpaceNamespace::ABC::instancemethod(int,bool) SpaceNamespace::ABC::instancemethod(int,bool)")
a:constmethod(1)
assert(v.declaration == "short * SpaceNamespace::ABC::constmethod(int) const SpaceNamespace::ABC::constmethod(int) const")
v.ABC.staticmethod(0, false)
assert(v.declaration == "short * SpaceNamespace::ABC::staticmethod(int,bool) SpaceNamespace::ABC::staticmethod(int,bool)")
a = nil
collectgarbage()
-- TODO no %exception on delete
-- assert(v.declaration == "SpaceNamespace::ABC::~ABC() SpaceNamespace::ABC::~ABC()") 
local abc = v.TemplateABC()
assert(v.declaration == "SpaceNamespace::Template< SpaceNamespace::ABC >::Template() SpaceNamespace::Template< SpaceNamespace::ABC >::Template()")
abc:tmethod(v.ABC())
assert(v.declaration == "std::string SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC) SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC)")
abc = nil
collectgarbage()
-- TODO no %exception on delete
-- assert(v.declaration == "SpaceNamespace::Template< SpaceNamespace::ABC >::~Template() SpaceNamespace::Template< SpaceNamespace::ABC >::~Template()")
v.globtemplate(v.TemplateABC())
assert(v.declaration == "void SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >) SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >)")
