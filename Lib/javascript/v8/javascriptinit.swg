%insert(init) %{
SWIGRUNTIME void
SWIG_V8_SetModule(swig_module_info *swig_module) {}

SWIGRUNTIME swig_module_info *
SWIG_V8_GetModule(void) {
  return 0;
}

#define SWIG_GetModule(clientdata)                SWIG_V8_GetModule()
#define SWIG_SetModule(clientdata, pointer)       SWIG_V8_SetModule(pointer)

%}

%insert(init) "swiginit.swg"
