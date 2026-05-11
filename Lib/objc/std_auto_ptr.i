/* -----------------------------------------------------------------------------
 * std_auto_ptr.i
 *
 * Objective-C support for std::auto_ptr.
 * ----------------------------------------------------------------------------- */

%define %auto_ptr(TYPE)
%typemap(imtype) std::auto_ptr< TYPE > "void *"
%typemap(objctype) std::auto_ptr< TYPE > "$objcclassname *"
%typemap(objcin) std::auto_ptr< TYPE > "[$objcinput swigRelease]"

%typemap(in) std::auto_ptr< TYPE > {
  $1.reset((TYPE *)$input);
}

%typemap(out) std::auto_ptr< TYPE > {
  $result = (void *)$1.release();
}

%typemap(objcout) std::auto_ptr< TYPE > {
  void *cPtr = $imcall;
  $objcclassname *ret = 0;
  if (cPtr)
    ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:YES] autorelease];
  return ret;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::auto_ptr< TYPE > ""

%template() std::auto_ptr< TYPE >;
%enddef

namespace std {
  template <class T> class auto_ptr {};
}
