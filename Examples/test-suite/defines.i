/* 
This testcase tests for embedded defines and embedded %constants
*/

%module defines

%inline %{

typedef struct EmbeddedDefines {
  int dummy;
#define  EMBEDDED_DEFINE 44
#ifdef SWIG
%constant EMBEDDED_SWIG_CONSTANT = 55;
#endif
} EmbeddedDefines;

%}
