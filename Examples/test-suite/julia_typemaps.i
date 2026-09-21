%module julia_typemaps
%inline %{
#include <stdexcept>
int allocated_count = 0;
int outstanding() { return allocated_count; }
%}
#ifdef SWIGJULIA
%insert("julia") %{const injected_value = 91%}
%typemap(ctype) int *allocated "int"
%typemap(jltype) int *allocated "Cint"
%typemap(jlparam) int *allocated "Integer"
%typemap(in) int *allocated %{
  $1 = new int($input);
  ++allocated_count;
%}
%typemap(freearg) int *allocated %{
  if ($1) { delete $1; --allocated_count; }
%}
%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) int *allocated "$1 = 1;"
#endif
%inline %{
int consume(int *allocated, bool fail) {
  if (fail) throw std::runtime_error("failure after allocation");
  return *allocated;
}
%}

#ifdef SWIGJULIA
%typemap(in, numinputs=0) int& OUTPUT (int temporary) %{ $1 = &temporary; %}
%typemap(argout) int& OUTPUT %{ $result = SWIG_AppendOutput($result, jl_box_int64(*$1)); %}
%apply int& OUTPUT { int& first, int& second };
#endif
%inline %{
void outputs(int& first, int& second) { first = 17; second = 23; }
%}
