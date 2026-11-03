open Swig
open Special_variables

let _ =
  assert (_ExceptionVars '(1.0, 2.0) as string =
    "result = Space::exceptionvars(arg1,arg2);  Space::exceptionvars  ExceptionVars   _wrap_ExceptionVarsspecial_variables  ");
  assert (_overloadedmethod '() as string =
    "result = Space::overloadedmethod();  Space::overloadedmethod  overloadedmethod  __SWIG_1 _wrap_overloadedmethod__SWIG_1special_variables  ");
  assert (_overloadedmethod '(10.0) as string =
    "result = Space::overloadedmethod(arg1);  Space::overloadedmethod  overloadedmethod  __SWIG_0 _wrap_overloadedmethod__SWIG_0special_variables  ");

  let _ = new_ABC '(0, 0.0) in
  assert (_declaration '() as string = "SpaceNamespace::ABC::ABC(int,double) SpaceNamespace::ABC::ABC(int,double)");
  let a = new_ABC '() in
  assert (_declaration '() as string = "SpaceNamespace::ABC::ABC() SpaceNamespace::ABC::ABC()");
  ignore (a -> instancemethod (1));
  assert (_declaration '() as string = "short *SpaceNamespace::ABC::instancemethod(int) SpaceNamespace::ABC::instancemethod(int)");
  ignore (a -> instancemethod (1, false));
  assert (_declaration '() as string = "short *SpaceNamespace::ABC::instancemethod(int,bool) SpaceNamespace::ABC::instancemethod(int,bool)");
  ignore (a -> constmethod (1));
  assert (_declaration '() as string = "short *SpaceNamespace::ABC::constmethod(int) const SpaceNamespace::ABC::constmethod(int) const");
  ignore (_ABC_staticmethod '(0, false));
  assert (_declaration '() as string = "short *SpaceNamespace::ABC::staticmethod(int,bool) SpaceNamespace::ABC::staticmethod(int,bool)");
  ignore (_ABC_funcptrmethod '(0));
  assert (_declaration '() as string = "int (*SpaceNamespace::ABC::funcptrmethod(int))(int,int) SpaceNamespace::ABC::funcptrmethod(int)");
  ignore (a -> toInt ());
  assert (_declaration '() as string = "SpaceNamespace::ABC::operator int() const SpaceNamespace::ABC::operator int() const");
  let funcptr = a -> "[funcptrvar]" () in
  assert (_declaration '() as string = "int (*SpaceNamespace::ABC::funcptrvar)(int) SpaceNamespace::ABC::funcptrvar");
  ignore (a -> "[funcptrvar]" (funcptr));
  assert (_declaration '() as string = "int (*SpaceNamespace::ABC::funcptrvar)(int) SpaceNamespace::ABC::funcptrvar");
  ignore (a -> "[stringvar]" ("abc"));
  assert (_declaration '() as string = "std::string SpaceNamespace::ABC::stringvar SpaceNamespace::ABC::stringvar");
  ignore (a -> "[stringvar]" ());
  assert (_declaration '() as string = "std::string SpaceNamespace::ABC::stringvar SpaceNamespace::ABC::stringvar");
  let funcptr = _globalfuncptrvar '() in
  assert (_declaration '() as string = "int (*SpaceNamespace::globalfuncptrvar)(int) SpaceNamespace::globalfuncptrvar");
  ignore (_globalfuncptrvar '(funcptr));
  assert (_declaration '() as string = "int (*SpaceNamespace::globalfuncptrvar)(int) SpaceNamespace::globalfuncptrvar");
  let holder = new_UnnamedEnumHolder '() in
  let e = holder -> "[unnamedenumvar]" () in
  assert (_declaration '() as string = "enum SpaceNamespace::UnnamedEnumHolder::unnamedenumvar SpaceNamespace::UnnamedEnumHolder::unnamedenumvar");
  ignore (holder -> "[unnamedenumvar]" (e));
  assert (_declaration '() as string = "enum SpaceNamespace::UnnamedEnumHolder::unnamedenumvar SpaceNamespace::UnnamedEnumHolder::unnamedenumvar");
  ignore (a -> "~" ());
  assert (_declaration '() as string = "SpaceNamespace::ABC::~ABC() SpaceNamespace::ABC::~ABC()");
  let abc = new_TemplateABC '() in
  assert (_declaration '() as string = "SpaceNamespace::Template< SpaceNamespace::ABC >::Template() SpaceNamespace::Template< SpaceNamespace::ABC >::Template()");
  let arg = new_ABC '() in
  ignore (abc -> tmethod (arg));
  assert (_declaration '() as string = "std::string SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC) SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC)");
  ignore (abc -> "~" ());
  assert (_declaration '() as string = "SpaceNamespace::Template< SpaceNamespace::ABC >::~Template() SpaceNamespace::Template< SpaceNamespace::ABC >::~Template()");
  let arg = new_TemplateABC '() in
  ignore (_globtemplate (arg));
  assert (_declaration '() as string = "void SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >) SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >)");
  let es = new_ExceptionSpec '() in
  assert (_declaration '() as string =
    "SpaceNamespace::ExceptionSpec::ExceptionSpec() noexcept(false) SpaceNamespace::ExceptionSpec::ExceptionSpec() noexcept(false)");
  ignore (es -> constnoexceptmethod (1));
  assert (_declaration '() as string =
    "short *SpaceNamespace::ExceptionSpec::constnoexceptmethod(int) const noexcept " ^
    "SpaceNamespace::ExceptionSpec::constnoexceptmethod(int) const noexcept");
  ignore (_ExceptionSpec_noexceptfuncptrmethod '(0));
  assert (_declaration '() as string =
    "int (*SpaceNamespace::ExceptionSpec::noexceptfuncptrmethod(int) noexcept)(int,int) " ^
    "SpaceNamespace::ExceptionSpec::noexceptfuncptrmethod(int) noexcept");
  ignore (es -> throwmethod (0));
  assert (_declaration '() as string =
    "void SpaceNamespace::ExceptionSpec::throwmethod(int) throw(int) SpaceNamespace::ExceptionSpec::throwmethod(int) throw(int)");
  ignore (es -> "~" ());
  assert (_declaration '() as string =
    "SpaceNamespace::ExceptionSpec::~ExceptionSpec() noexcept SpaceNamespace::ExceptionSpec::~ExceptionSpec() noexcept");
  ignore (_typedeffunction '(0));
  assert (_declaration '() as string = "short *SpaceNamespace::typedeffunction(int) SpaceNamespace::typedeffunction(int)");
  let tm = new_TypedefMethods '() in
  ignore (tm -> typedefmethod (0));
  assert (_declaration '() as string =
    "short *SpaceNamespace::TypedefMethods::typedefmethod(int) const SpaceNamespace::TypedefMethods::typedefmethod(int) const");
;;
