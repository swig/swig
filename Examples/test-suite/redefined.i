%module redefined

#if 1
 //
 // All these repeated declarations are not redefinitions,
 // and they are valid C++ code, therefore, we skip 
 // swig redefined warnings.
 //
%define uja
  aju;
%enddef

%define uja
  aju;
%enddef

%constant int agua = 0;
%constant int agua = 0;

%inline %{

#define REPEATED 1
#define REPEATED 1

#define MACROREP(x) x
#define MACROREP(x) x

  typedef int Int;
  typedef int Int;

  int hello(int);
  inline int hello(int) { return 0; };
  
  struct Hello 
  {
    typedef int Int;
    typedef int Int;
    friend int hello(int);    
  };

  struct Hello2
  {
    typedef int Int;
    typedef int Int;
    friend int hello(int);
  };
  
%}


#else

//
// the %extend directive ALWAYS emits redefined warnings,
// since it is not only introducing a declaration, but a redefinition.
//
%extend Hello {
  int hi(int) { return 0; };
}

//
// All these repeated declarations are really redefinitions,
// therefore, swig must produce a redefined warning
//

%constant int agua = 0;
%constant int agua = 1;


%inline %{

#define REPEATED 1
#define REPEATED 2

#define MACROREP(x) x
#define MACROREP(x) x*2

  typedef int Int;
  typedef double Int;

  int hello(int);
  inline double hello(int) { return 0; };
  
  struct Hello 
  {
    typedef int Int;
    typedef double Int;
    friend short hello(int);
    int hi(int) { return 0; };
  };
  
%}
#endif
