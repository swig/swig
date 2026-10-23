%module  nested_inheritance_interface

%warnfilter(SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE); /* languages not supporting multiple inheritance or %interface */

#if defined(SWIGCSHARP) || defined(SWIGJAVA_SOURCE)
%include <swiginterface.i>
%interface(IA)
#else
%feature ("flatnested");
#endif

%inline %{
struct IA {};
struct B { struct N : IA {}; };
%}
