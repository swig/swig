// Tests the csbegin, dbegin and javabegin for %module

%define CSBEGIN_CODE
"
/* Copyright statement */
using System.Text;
// #nullable enable // commented out: only works with very modern versions of C#
"
%enddef

%module(csbegin=CSBEGIN_CODE, dbegin="/* D common comment */", javabegin="/* Java common comment */\n") begin_code


%inline %{
struct ABC {
    void abc_method() {}
};
%}

#if defined(SWIGCSHARP)
%extend ABC {
%proxycode %{
public StringBuilder TestBeginProxy(string input) {
  return new StringBuilder(input);
}
%}
}
%pragma(csharp) imclasscode=%{
public StringBuilder TestBeginIM(string input) {
  return new StringBuilder(input);
}
%}
%pragma(csharp) modulecode=%{
public StringBuilder TestBeginModule(string input) {
  return new StringBuilder(input);
}
%}
#endif

