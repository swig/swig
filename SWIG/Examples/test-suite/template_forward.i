%module template_forward

%{
namespace foo {
template<class T> class bar { };
}
%}

namespace foo {
   template<class T> class bar;
};

%inline %{
namespace foo {
   double test1(const bar<double> &x) { return 0; }
   bar<double> test2() {
	return bar<double>();
   }
}
%}
