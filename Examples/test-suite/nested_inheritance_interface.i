%module  nested_inheritance_interface

%warnfilter(SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE); /* languages not supporting multiple inheritance or %interface */

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include <swiginterface.i>
%interface(IA)
#endif

#if !defined(SWIGCSHARP) && !defined(SWIGJAVA)
%feature ("flatnested");
#endif


%inline %{
struct IA {};
struct B { struct N : IA {}; };
%}
