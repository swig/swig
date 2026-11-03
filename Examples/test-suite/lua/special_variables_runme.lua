local v=require("special_variables")

assert(v.ExceptionVars(1, 2) == "result = Space::exceptionvars(arg1,arg2);  Space::exceptionvars  ExceptionVars   _wrap_ExceptionVars  ")
assert(v.overloadedmethod() ==   "result = Space::overloadedmethod();  Space::overloadedmethod  overloadedmethod  __SWIG_1 _wrap_overloadedmethod__SWIG_1  ")
assert(v.overloadedmethod(10) == "result = Space::overloadedmethod(arg1);  Space::overloadedmethod  overloadedmethod  __SWIG_0 _wrap_overloadedmethod__SWIG_0  ")

local a = v.ABC(0, 0)
assert(v.declaration == "SpaceNamespace::ABC::ABC(int,double) SpaceNamespace::ABC::ABC(int,double)")
local a = v.ABC()
assert(v.declaration == "SpaceNamespace::ABC::ABC() SpaceNamespace::ABC::ABC()")
a:instancemethod(1)
assert(v.declaration == "short *SpaceNamespace::ABC::instancemethod(int) SpaceNamespace::ABC::instancemethod(int)")
a:instancemethod(1, false)
assert(v.declaration == "short *SpaceNamespace::ABC::instancemethod(int,bool) SpaceNamespace::ABC::instancemethod(int,bool)")
a:constmethod(1)
assert(v.declaration == "short *SpaceNamespace::ABC::constmethod(int) const SpaceNamespace::ABC::constmethod(int) const")
v.ABC.staticmethod(0, false)
assert(v.declaration == "short *SpaceNamespace::ABC::staticmethod(int,bool) SpaceNamespace::ABC::staticmethod(int,bool)")
v.ABC.funcptrmethod(0)
assert(v.declaration == "int (*SpaceNamespace::ABC::funcptrmethod(int))(int,int) SpaceNamespace::ABC::funcptrmethod(int)")
a:toInt()
assert(v.declaration == "SpaceNamespace::ABC::operator int() const SpaceNamespace::ABC::operator int() const")
a.funcptrvar = nil
assert(v.declaration == "int (*SpaceNamespace::ABC::funcptrvar)(int) SpaceNamespace::ABC::funcptrvar")
local f = a.funcptrvar
assert(v.declaration == "int (*SpaceNamespace::ABC::funcptrvar)(int) SpaceNamespace::ABC::funcptrvar")
a.stringvar = "abc"
assert(v.declaration == "std::string SpaceNamespace::ABC::stringvar SpaceNamespace::ABC::stringvar")
local s = a.stringvar
assert(v.declaration == "std::string SpaceNamespace::ABC::stringvar SpaceNamespace::ABC::stringvar")
v.globalfuncptrvar = nil
assert(v.declaration == "int (*SpaceNamespace::globalfuncptrvar)(int) SpaceNamespace::globalfuncptrvar")
f = v.globalfuncptrvar
assert(v.declaration == "int (*SpaceNamespace::globalfuncptrvar)(int) SpaceNamespace::globalfuncptrvar")
local holder = v.UnnamedEnumHolder()
holder.unnamedenumvar = v.UnnamedEnumHolder.UnnamedMemberEnumItem
assert(v.declaration == "enum SpaceNamespace::UnnamedEnumHolder::unnamedenumvar SpaceNamespace::UnnamedEnumHolder::unnamedenumvar")
local e = holder.unnamedenumvar
assert(v.declaration == "enum SpaceNamespace::UnnamedEnumHolder::unnamedenumvar SpaceNamespace::UnnamedEnumHolder::unnamedenumvar")
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
local es = v.ExceptionSpec()
assert(v.declaration == "SpaceNamespace::ExceptionSpec::ExceptionSpec() noexcept(false) SpaceNamespace::ExceptionSpec::ExceptionSpec() noexcept(false)")
es:constnoexceptmethod(1)
assert(v.declaration == "short *SpaceNamespace::ExceptionSpec::constnoexceptmethod(int) const noexcept " ..
                        "SpaceNamespace::ExceptionSpec::constnoexceptmethod(int) const noexcept")
v.ExceptionSpec.noexceptfuncptrmethod(0)
assert(v.declaration == "int (*SpaceNamespace::ExceptionSpec::noexceptfuncptrmethod(int) noexcept)(int,int) " ..
                        "SpaceNamespace::ExceptionSpec::noexceptfuncptrmethod(int) noexcept")
es:throwmethod(0)
assert(v.declaration == "void SpaceNamespace::ExceptionSpec::throwmethod(int) throw(int) SpaceNamespace::ExceptionSpec::throwmethod(int) throw(int)")
v.typedeffunction(0)
assert(v.declaration == "short *SpaceNamespace::typedeffunction(int) SpaceNamespace::typedeffunction(int)")
local tm = v.TypedefMethods()
tm:typedefmethod(0)
assert(v.declaration == "short *SpaceNamespace::TypedefMethods::typedefmethod(int) const SpaceNamespace::TypedefMethods::typedefmethod(int) const")
