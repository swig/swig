/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * The typemaps here allow handling functions returning std::unique_ptr<>,
 * which is the most common use of this type. If you have functions taking it
 * as parameter, these typemaps can't be used for them and you need to do
 * something else (e.g. use shared_ptr<> which SWIG supports fully).
 * ----------------------------------------------------------------------------- */

%define %unique_ptr(TYPE)
%typemap(in, noblock=1) std::unique_ptr< TYPE > (void *argp = 0, int res = 0) {
  res = SWIG_ConvertPtr($input, &argp, $descriptor(TYPE *), SWIG_POINTER_RELEASE | %convertptr_flags);
  if (!SWIG_IsOK(res)) {
    if (res == SWIG_ERROR_RELEASE_NOT_OWNED) {
      %releasenotowned_fail(res, "TYPE *", $symname, $argnum);
    } else {
      %argument_fail(res, "TYPE *", $symname, $argnum);
    }
  }
  $1.reset((TYPE *)argp);
}

%typemap (out) std::unique_ptr< TYPE > %{
   %set_output(SWIG_NewPointerObj($1.release(), $descriptor(TYPE *), SWIG_POINTER_OWN | %newpointer_flags));
%}

%template() std::unique_ptr< TYPE >;
%enddef

namespace std {
   template <class T> class unique_ptr {};
}
