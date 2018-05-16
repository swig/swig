/* Tests the use of %template with namespaces */

%module namespace_template

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) test::vector<int>;        /* Ruby, wrong class name */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) test::vector<short>;      /* Ruby, wrong class name */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) test::vector<long>;       /* Ruby, wrong class name */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) test::vector<test::Char>; /* Ruby, wrong class name */

%{
#ifdef max
#undef max
#endif
%}

%{
namespace test {
   template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
   template<typename T> class vector { 
	public:
	   vector() { }
          ~vector() { }
           char * blah(T x) {
              return (char *) "vector::blah";
           }
           void vectoruse(vector<T> a, test::vector<T> b) {}
   }; 
}
%}

namespace test {
   template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
   template<typename T> class vector { 
	public:
	   vector() { }
          ~vector() { }
           char * blah(T x) {
              return (char *) "vector::blah";
           }
           void vectoruse(vector<T> a, test::vector<T> b) {}
   }; 
}

using namespace test;
%template(maxint) max<int>;
%template(vectorint) vector<int>;

namespace test {
   %template(maxshort) max<short>;
   %template(vectorshort) vector<short>;
}

namespace test {
   %template(maxlong) max<long>;
   %template(vectorlong) vector<long>;
}

%inline %{

namespace test {
   typedef char Char;
}

%}

namespace test {
   %template(maxchar) max<Char>;
   %template(vectorchar) vector<Char>;
}

