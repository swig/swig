%module extern_declaration 

// Test different calling conventions on Windows. Old versions of SWIG generated
// an incorrect extern declarations that wouldn't compile with Windows compilers.
#define SWIGEXPORT
#define SWIGSTDCALL
#define DLLIMPORT

%{
#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  define DLLIMPORT __declspec(dllimport)
#else
#  define DLLIMPORT
#endif
%}

DLLIMPORT extern int externimport(int i);
SWIGEXPORT extern int externexport(int);
extern int SWIGSTDCALL externstdcall(int);

%{
SWIGEXPORT extern int externimport(int i) { return i; }
SWIGEXPORT extern int externexport(int i) { return i; }
extern int SWIGSTDCALL externstdcall(int i) { return i; }
%}


