// Test the optimal attribute in the out typemap
%module typemap_out_optimal

// Just the following languages tested
#if defined (SWIGCSHARP) || defined (SWIGD)
%typemap(out, optimal="1") SWIGTYPE %{
  $result = new $1_ltype($1);
%}
#elif defined (SWIGJAVA)
%typemap(out, optimal="1") SWIGTYPE %{ 
  *($&1_ltype*)&$result = new $1_ltype($1);
%}
#elif defined (SWIGUTL)
%typemap(out,noblock="1", optimal="1") SWIGTYPE {
  %set_output(SWIG_NewPointerObj(new $1_ltype($1), $&descriptor, SWIG_POINTER_OWN | %newpointer_flags));
}
#endif

%ignore XX::operator=;

%inline %{
#include <iostream>
using namespace std;

struct XX {
  XX() { if (trace) cout << "XX()" << endl; }
  XX(int i) { if (trace) cout << "XX(" << i << ")" << endl; }
  XX(const XX &other) { if (trace) cout << "XX(const XX &)" << endl; }
  XX& operator =(const XX &other) { if (trace) cout << "operator=(const XX &)" << endl; return *this; }
  ~XX() { if (trace) cout << "~XX()" << endl; }

// Note: best observed RVO for C#, Java and Python with g++-6 to g++-10 (just one constructor and one destructor call)
  static XX create() {
    return XX(123);
  }
  static const XX createConst() {
    return XX(456);
  }
  static bool trace;
};
bool XX::trace = true;
%}

