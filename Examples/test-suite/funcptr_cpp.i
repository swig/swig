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
int call4(int & (*d)(int &, int *), int a, int b) { return d(a, &b); }
int call5(int & (*d)(int &, int const * const), int a, int b) { return d(a, &b); }
int callconst1(int (* const d)(const int &, int), int a, int b) { return d(a, b); }
%}

%constant int (*ADD_BY_VALUE)(const int &, int) = addByValue;
%constant int * (*ADD_BY_POINTER)(const int &, int) = addByPointer;
%constant int & (*ADD_BY_REFERENCE)(const int &, int) = addByReference;
%constant int (* const ADD_BY_VALUE_C)(const int &, int) = addByValue;

// FIXME: We've only fixed `noexcept` on parameter types which are function
// pointers to parse - the generated code has `noexcept` in the wrong place
// and won't compile so for now don't try to actually wrap the function.
%ignore f2087a;
%ignore f2087b;

%inline %{
typedef int AddByValueTypedef(const int &a, int b);
typedef int * AddByPointerTypedef(const int &a, int b);
typedef int & AddByReferenceTypedef(const int &a, int b);
void *typedef_call1(AddByValueTypedef *& precallback, AddByValueTypedef * postcallback) { return 0; }
void *typedef_call2(AddByPointerTypedef *& precallback, AddByPointerTypedef * postcallback) { return 0; }
void *typedef_call3(AddByReferenceTypedef *& precallback, AddByReferenceTypedef * postcallback) { return 0; }

// Regression tests for #2087 (noexcept on a function pointer parameter type):
void f2087a(int (*g)() noexcept) { (void)g; }
void f2087b(int const (*g)() noexcept) { (void)g; }
%}
