/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * SWIG library file for handling std::unique_ptr.
 *
 * Returning a std::unique_ptr from a wrapped function:
 *   Memory ownership is passed (moved) from the std::unique_ptr in the C++ layer
 *   to the proxy class when returning a std::unique_ptr by value from a function.
 *   Memory ownership is not moved when returning by any sort of reference.
 *
 * Passing a std::unique_ptr as a parameter to a wrapped function:
 *   Memory ownership is passed from the proxy class to the std::unique_ptr in the
 *   C++ layer when passed as a parameter by value, rvalue reference or non-const
 *   lvalue reference. Memory ownership is not transferred when passing by const
 *   lvalue reference.
 * ----------------------------------------------------------------------------- */

%include <unique_ptr.swg>

%define %unique_ptr(TYPE)
%typemap(in, noblock=1) std::unique_ptr< TYPE > (void *argp = 0, int res = 0) {
  res = SWIG_ConvertPtr($input, &argp, $descriptor(TYPE *), SWIG_POINTER_RELEASE);
  if (!SWIG_IsOK(res)) {
    if (res == SWIG_ERROR_RELEASE_NOT_OWNED) {
      scheme_signal_error(FUNC_NAME ": cannot release ownership as memory is not owned for argument $argnum of type 'TYPE *'");
    } else {
      %argument_fail(res, "TYPE *", $symname, $argnum);
    }
  }
  $1.reset((TYPE *)argp);
}

%typemap(in, noblock=1) std::unique_ptr< TYPE > & (void *argp = 0, int res = 0, std::unique_ptr< TYPE > uptr), std::unique_ptr< TYPE > && (void *argp = 0, int res = 0, std::unique_ptr< TYPE > uptr) {
  res = SWIG_ConvertPtr($input, &argp, $descriptor(TYPE *), SWIG_POINTER_RELEASE);
  if (!SWIG_IsOK(res)) {
    if (res == SWIG_ERROR_RELEASE_NOT_OWNED) {
      scheme_signal_error(FUNC_NAME ": cannot release ownership as memory is not owned for argument $argnum of type 'TYPE *'");
    } else {
      %argument_fail(res, "TYPE *", $symname, $argnum);
    }
  }
  uptr.reset((TYPE *)argp);
  $1 = &uptr;
}

%typemap(in, noblock=1, fragment="SwigNoDeleteUniquePtr") const std::unique_ptr< TYPE > & (void *argp = 0, int res = 0, swig::NoDeleteUniquePtr< TYPE > ndup) {
  res = SWIG_ConvertPtr($input, &argp, $descriptor(TYPE *), 0);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "TYPE *", $symname, $argnum);
  }
  ndup.uptr.reset((TYPE *)argp);
  $1 = &ndup.uptr;
}

%typemap (out) std::unique_ptr< TYPE > %{
  %set_output(SWIG_NewPointerObj($1.release(), $descriptor(TYPE *), SWIG_POINTER_OWN));
%}
%typemap (out) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && %{
  %set_output(SWIG_NewPointerObj($1->get(), $descriptor(TYPE *), $owner));
%}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *", noblock=1) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && {
  void *vptr = 0;
  int res = SWIG_ConvertPtr($input, &vptr, $descriptor(TYPE *), 0);
  $1 = SWIG_CheckState(res);
}

%template() std::unique_ptr< TYPE >;
%enddef
