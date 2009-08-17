/* Test whether varios enums in C. */

%module "enums"

/* Suppress warning messages from the Ruby module for all of the following.. */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) boo;
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) hoo;
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) globalinstance1;
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) globalinstance2;
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) globalinstance3;

%inline %{

typedef enum { 
    CSP_ITERATION_FWD,
    CSP_ITERATION_BWD = 11
} foo1;

typedef enum foo2 {
    ABCDE = 0,
    FGHJI = 1
} foo3;

void
bar1(foo1 x) {}

void
bar2(enum foo2 x) {}

void 
bar3(foo3 x) {}

enum sad { boo, hoo = 5 };

#ifdef __cplusplus /* For Octave and g++ which compiles C test code as C++ */
extern "C" {
#endif
/* Unnamed enum instance */
enum { globalinstance1, globalinstance2, globalinstance3 = 30 } GlobalInstance;
#ifdef __cplusplus
}
#endif

/* Anonymous enum */
enum { AnonEnum1, AnonEnum2 = 100 };

%}

%inline %{

typedef struct _Foo {
  enum { BAR1, BAR2 } e;
} Foo;

%}

  
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) _iFoo;

#ifndef __cplusplus
%inline %{
typedef struct _iFoo 
{ 
    enum { 
      Phoo = +50,
      Char = 'a'
    } e; 
} iFoo; 
%}
#else
%inline %{
struct iFoo 
{ 
    enum { 
      Phoo = +50,
      Char = 'a'
    }; 
}; 
%}

#endif
