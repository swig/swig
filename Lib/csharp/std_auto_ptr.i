/*
    The typemaps here allow to handle functions returning std::auto_ptr<>,
    which is the most common use of this type. If you have functions taking it
    as parameter, these typemaps can't be used for them and you need to do
    something else (e.g. use shared_ptr<> which SWIG supports fully).
 */

%include <auto_ptr.i>

%define %auto_ptr(TYPE)
%typemap (ctype) SWIG_AUTO_PTR_FULL_NAME<TYPE > "void *"
%typemap (imtype, out="System.IntPtr") SWIG_AUTO_PTR_FULL_NAME<TYPE > "HandleRef"
%typemap (cstype) SWIG_AUTO_PTR_FULL_NAME<TYPE > "$typemap(cstype, TYPE)"
%typemap (out) SWIG_AUTO_PTR_FULL_NAME<TYPE > %{
   $result = (void *)$1.release();
%}
%typemap(csout, excode=SWIGEXCODE) SWIG_AUTO_PTR_FULL_NAME<TYPE > {
     System.IntPtr cPtr = $imcall;
     $typemap(cstype, TYPE) ret = (cPtr == System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
     return ret;
   }
%template() SWIG_AUTO_PTR_FULL_NAME<TYPE >;
%enddef
