/* This testcase checks whether Swig correctly parses the template aliasing. */
%module cpp0x_template_typedefs

%inline %{
template< typename T1, typename T2, int >
class SomeType {
	T1 a;
	T2 b;
	int c;
};

template< typename T2 >
using TypedefName = SomeType<char*, T2, 5>;

typedef void (*PFD)(double);            // Old style
using PF = void (*)(double);            // New introduced syntax
%}

