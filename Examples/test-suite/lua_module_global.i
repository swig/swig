%module lua_module_global
%{
    const char *hi_mom() { return "hi mom!"; }
%}
const char *hi_mom();
