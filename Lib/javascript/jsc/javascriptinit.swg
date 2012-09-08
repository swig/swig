%insert(init) %{
SWIGRUNTIME void
SWIG_JSC_SetModule(swig_module_info *swig_module) {}

SWIGRUNTIME swig_module_info *
SWIG_JSC_GetModule(void) {
  return 0;
}

#define SWIG_GetModule(clientdata)                SWIG_JSC_GetModule()
#define SWIG_SetModule(clientdata, pointer)       SWIG_JSC_SetModule(pointer)

%}

%insert(init) "swiginit.swg"
