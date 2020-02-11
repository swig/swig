/*
    The typemaps here allow to handle functions returning std::auto_ptr<>,
    which is the most common use of this type. If you have functions taking it
    as parameter, these typemaps can't be used for them and you need to do
    something else (e.g. use shared_ptr<> which SWIG supports fully).
 */

%include <auto_ptr.i>

%define %auto_ptr(TYPE)
%typemap (out) SWIG_AUTO_PTR_FULL_NAME<TYPE > %{
   %set_output(SWIG_NewPointerObj($1.release(), $descriptor(TYPE *), SWIG_POINTER_OWN | %newpointer_flags));
%}
%template() SWIG_AUTO_PTR_FULL_NAME<TYPE >;
%enddef
