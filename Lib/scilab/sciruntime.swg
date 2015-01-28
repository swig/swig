%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";

#define %scilabcode %insert("scilab")

%insert(runtime) "scirun.swg";

%init %{
#define SWIG_GetModule(clientdata) SWIG_Scilab_GetModule()
#define SWIG_SetModule(clientdata, pointer) SWIG_Scilab_SetModule(pointer)

SWIGRUNTIME swig_module_info*
SWIG_Scilab_GetModule(void)
{
  return NULL;
}

SWIGRUNTIME void
SWIG_Scilab_SetModule(swig_module_info *swig_module)
{
}
%}

%insert(init) "swiginit.swg"

%init %{
#ifdef __cplusplus
extern "C"
#endif
int <module>_Init(SWIG_GatewayParameters) {
  SWIG_InitializeModule(NULL);
  SWIG_CreateScilabVariables(pvApiCtx);
%}
