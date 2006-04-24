/* Test %apply for char *, signed char *, unsigned char * */

%module apply_strings

%apply char * {UCharPtr};
%apply char * {SCharPtr};

%inline %{
  typedef unsigned char* UCharPtr;
  typedef signed char* SCharPtr;

  UCharPtr UCharFunction(UCharPtr str) { return str; }
  SCharPtr SCharFunction(SCharPtr str) { return str; }
%}

%apply SWIGTYPE* {CharPtr};

%inline %{
  typedef char* CharPtr;

  CharPtr CharFunction(CharPtr buf) { return buf; }
%}
