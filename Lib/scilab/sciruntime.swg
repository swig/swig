%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) %{

void SWIG_Error(int code, const char *msg) {
  Scierror(code, _("%s\n"), msg);
}

#define SWIG_contract_assert(expr, msg) if (!(expr)) { SWIG_Error(999, msg); } else 

%}
