%module funcptr_cpp

%{
#if defined(__SUNPRO_CC)
#pragma error_messages (off, badargtype2w) /* Formal argument ... is being passed extern "C" ... */
#endif
%}

%inline %{

int addByValue(const int &a, int b) { return a+b; }
int * addByPointer(const int &a, int b) { static int val; val = a+b; return &val; }
int & addByReference(const int &a, int b) { static int val; val = a+b; return val; }

int call1(int (*d)(const int &, int), int a, int b) { return d(a, b); }
int call2(int * (*d)(const int &, int), int a, int b) { return *d(a, b); }
int call3(int & (*d)(const int &, int), int a, int b) { return d(a, b); }
%}

%constant int (*ADD_BY_VALUE)(const int &, int) = addByValue;
%constant int * (*ADD_BY_POINTER)(const int &, int) = addByPointer;
%constant int & (*ADD_BY_REFERENCE)(const int &, int) = addByReference;
