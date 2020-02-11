/*
    The typemaps here allow to handle functions returning std::auto_ptr<>,
    which is the most common use of this type. If you have functions taking it
    as parameter, these typemaps can't be used for them and you need to do
    something else (e.g. use shared_ptr<> which SWIG supports fully).
 */

%include <auto_ptr.i>

%define %auto_ptr(TYPE)
%typemap (jni) SWIG_AUTO_PTR_FULL_NAME<TYPE > "jlong"
%typemap (jtype) SWIG_AUTO_PTR_FULL_NAME<TYPE > "long"
%typemap (jstype) SWIG_AUTO_PTR_FULL_NAME<TYPE > "$typemap(jstype, TYPE)"

%typemap (out) SWIG_AUTO_PTR_FULL_NAME<TYPE > %{
   jlong lpp = 0;
   *(TYPE**) &lpp = $1.release();
   $result = lpp;
%}
%typemap(javaout) SWIG_AUTO_PTR_FULL_NAME<TYPE > {
     long cPtr = $jnicall;
     return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
   }
%template() SWIG_AUTO_PTR_FULL_NAME<TYPE >;
%enddef
