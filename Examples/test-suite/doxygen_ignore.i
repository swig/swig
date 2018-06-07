%module doxygen_ignore

%feature("doxygen:ignore:transferfull");
%feature("doxygen:ignore:compileroptions", range="line");
%feature("doxygen:ignore:forcpponly", range="end");

#ifdef SWIGJAVA
%feature("doxygen:ignore:beginJavaOnly", range="end:endJavaOnly", contents="parse");
%feature("doxygen:ignore:beginPythonOnly", range="end:endPythonOnly");
#elif defined(SWIGPYTHON)
%feature("doxygen:ignore:beginJavaOnly", range="end:endJavaOnly");
%feature("doxygen:ignore:beginPythonOnly", range="end:endPythonOnly", contents="parse");
#else
%feature("doxygen:ignore:beginJavaOnly", range="end:endJavaOnly");
%feature("doxygen:ignore:beginPythonOnly", range="end:endPythonOnly");
#endif

%inline %{

/**
    A contrived example of ignoring too many commands in one comment.

    @forcpponly
    This is C++-specific.
    @endforcpponly

    @beginJavaOnly
    This is specific to @e Java.
    @endJavaOnly

    @beginPythonOnly
    This is specific to @b Python.
    @endPythonOnly

    @transferfull Command ignored, but anything here is still included.

    @compileroptions This function must be compiled with /EHa when using MSVC.
 */
int * func() { return 0; }

%}
