%module primitive_fragments
%define FRAGMENT_VALUE(TYPE, NAME, TS)
%inline %{ typedef TYPE NAME; %}
%typemap(ctype) NAME "EM_VAL"
%typemap(in, fragment=SWIG_AsVal_frag(TYPE), tsstub_in=TS) NAME {
  if (!SWIG_IsOK(SWIG_AsVal(TYPE)(reinterpret_cast<void *>($input), &$1)))
    SWIG_exception_fail(SWIG_TypeError, "Invalid fragment input");
}
%typemap(out, fragment=SWIG_From_frag(TYPE), tsstub_out=TS) NAME {
  $result = reinterpret_cast<EM_VAL>(SWIG_From(TYPE)($1));
}
%typemap(jsarg) NAME "__unwrap($input)"
%typemap(jsout) NAME "__from_handle($call)"
%enddef
FRAGMENT_VALUE(bool, FragmentBool, "boolean")
FRAGMENT_VALUE(int, FragmentInt, "number | bigint")
FRAGMENT_VALUE(long long, FragmentWide, "bigint")
FRAGMENT_VALUE(unsigned long long, FragmentUnsigned, "bigint")
FRAGMENT_VALUE(double, FragmentDouble, "number")
%insert("js") %{
__m.handle_count = () => M.count_emval_handles();
%}
%inline %{
bool scalar_boolean(bool value) { return value; }
FragmentBool boolean_value(FragmentBool value) { return value; }
FragmentInt integer_value(FragmentInt value) { return value; }
FragmentWide wide_value(FragmentWide value) { return value; }
FragmentUnsigned unsigned_value(FragmentUnsigned value) { return value; }
FragmentDouble double_value(FragmentDouble value) { return value; }
%}
