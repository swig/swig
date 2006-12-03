/* Test %apply for char *, signed char *, unsigned char * */

%module(directors="1") apply_strings

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) DirectorTest;

%apply char * {UCharPtr};
%apply char * {SCharPtr};
%apply const char * {CUCharPtr};
%apply const char * {CSCharPtr};

%inline %{
  typedef unsigned char* UCharPtr;
  typedef signed char* SCharPtr;
  typedef const unsigned char* CUCharPtr;
  typedef const signed char* CSCharPtr;

  UCharPtr UCharFunction(UCharPtr str) { return str; }
  SCharPtr SCharFunction(SCharPtr str) { return str; }
  CUCharPtr CUCharFunction(CUCharPtr str) { return str; }
  CSCharPtr CSCharFunction(CSCharPtr str) { return str; }
%}

%typemap(freearg) SWIGTYPE * ""
%apply SWIGTYPE* {CharPtr};
%apply SWIGTYPE* {CCharPtr};

%inline %{
  typedef char* CharPtr;
  typedef const char* CCharPtr;

  CharPtr CharFunction(CharPtr buffer) { return buffer; }
  CCharPtr CCharFunction(CCharPtr buffer) { return buffer; }
%}

// unsigned char* as strings
#if !defined(SWIGUTL)
%apply char [ANY] {TAscii[ANY]}
%apply char [] {TAscii []}
%apply char * {TAscii *}
#else
#warning "UTL needs fixing for these typemaps"
#endif

%inline %{
typedef unsigned char TAscii;
typedef struct {
   TAscii DigitsMemberA[20];
   TAscii *DigitsMemberB;
} TNumber;
 
TAscii DigitsGlobalA[20];
TAscii DigitsGlobalB[] = {(unsigned char)'A', (unsigned char)'B', 0};
TAscii *DigitsGlobalC;

%} 

// Director test
%feature("director");

%inline %{
  struct DirectorTest {
    virtual UCharPtr UCharFunction(UCharPtr str) { return str; }
    virtual SCharPtr SCharFunction(SCharPtr str) { return str; }
    virtual CUCharPtr CUCharFunction(CUCharPtr str) { return str; }
    virtual CSCharPtr CSCharFunction(CSCharPtr str) { return str; }
    virtual CharPtr CharFunction(CharPtr buffer) { return buffer; }
    virtual CCharPtr CCharFunction(CCharPtr buffer) { return buffer; }
    virtual ~DirectorTest() {}
  };
%}


