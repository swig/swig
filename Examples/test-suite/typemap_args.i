%module typemap_args

%define MYTYPECHECK_int_YAY    SWIG_TYPECHECK_INTEGER %enddef
%define MYTYPECHECK_double_YAY SWIG_TYPECHECK_DOUBLE  %enddef

%fragment("includeme"{int}, "header") %{
#define INCLUDED_INT_TYPECHECK
%}
%fragment("includeme"{double}, "header") %{
#define INCLUDED_DOUBLE_TYPECHECK
%}

%define %add_typecheck(TYPE)
%typemap(typecheck, precedence={MYTYPECHECK_ ## TYPE ## _YAY}, fragment="includeme"{TYPE}) TYPE {
  $1 = (TYPE)$1;
}
%enddef

%add_typecheck(int)
%add_typecheck(double)

%inline %{
int foo(int a) { return a; }
double foo(double a) { return a * 2; }
%}

%{
/* If these two lines don't compile out, it's because the
 * necessary fragment wasn't included */
INCLUDED_INT_TYPECHECK;
INCLUDED_DOUBLE_TYPECHECK;
%}
