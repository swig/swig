/* This interface file checks whether the SWIG parses the throw
   directive in combination with the const directive.  Bug reported by
   Scott B. Drummonds, 08 June 2001.  
*/

%module cplusplus_throw

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
#if __GNUC__ >= 7
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wdeprecated" // dynamic exception specifications are deprecated in C++11
#endif
%}

%nodefaultctor;

%inline %{

class Foo { };

class Bar {
public:
  void baz() const { };
  void foo() throw (Foo) { };
  void bazfoo() const throw (int) { };
};

%}

%{
#if defined(_MSC_VER)
  #pragma warning(default: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
#if __GNUC__ >= 7
  #pragma GCC diagnostic pop
#endif
%}
