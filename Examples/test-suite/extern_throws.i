%module extern_throws

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
#if __GNUC__ >= 7
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wdeprecated" // dynamic exception specifications are deprecated in C++11
#endif
%}

#if defined(SWIGMATLAB)
%rename(get1) get;
#endif

%inline %{
#include <exception>
extern int get() throw(std::exception);

%}

%{
int get() throw(std::exception) { return 0; }
%}

%{
#if defined(_MSC_VER)
  #pragma warning(default: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
#if __GNUC__ >= 7
  #pragma GCC diagnostic pop
#endif
%}
