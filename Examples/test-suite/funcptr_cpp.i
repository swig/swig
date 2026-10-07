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

%inline %{
typedef int AddByValueTypedef(const int &a, int b);
typedef int * AddByPointerTypedef(const int &a, int b);
typedef int & AddByReferenceTypedef(const int &a, int b);
void *typedef_call1(AddByValueTypedef *& precallback, AddByValueTypedef * postcallback) { return 0; }
void *typedef_call2(AddByPointerTypedef *& precallback, AddByPointerTypedef * postcallback) { return 0; }
void *typedef_call3(AddByReferenceTypedef *& precallback, AddByReferenceTypedef * postcallback) { return 0; }

typedef int AddByValueConstTypedef(const int &a, int b) const;
struct AddByValueHolder {
  AddByValueTypedef byValueMethod;
  AddByValueConstTypedef byValueConstMethod;
  AddByValueTypedef &byValueRef;
  AddByValueHolder() : byValueRef(addByValue) {}
};
int AddByValueHolder::byValueMethod(const int &a, int b) { return a + b; }
int AddByValueHolder::byValueConstMethod(const int &a, int b) const { return a + b; }

// Reference to a function declared through a function typedef, wrapped as a function
AddByValueTypedef &addByValueRef = addByValue;

// Reference to a function as a parameter or return type
int callref1(int (&d)(const int &, int), int a, int b) { return d(a, b); }
int callref2(AddByValueTypedef &d, int a, int b) { return d(a, b); }
int (&getAddByValueRef1())(const int &, int) { return addByValue; }
AddByValueTypedef &getAddByValueRef2() { return addByValue; }
struct AddByValueRefHolder {
  AddByValueTypedef &fnRef;
  AddByValueRefHolder(AddByValueTypedef &f) : fnRef(f) {}
  int call(int a, int b) { return fnRef(a, b); }
};
%}

%{
int array4[4] = {10, 20, 30, 40};
%}

%inline %{
// A reference to an array returned as a pointer to the array, as when the array type is a typedef
typedef int Array4[4];
int (&getArrayRef1())[4] { return array4; }
Array4 &getArrayRef2() { return array4; }
int arrayRefSum(int (*a)[4]) { return (*a)[0] + (*a)[1] + (*a)[2] + (*a)[3]; }
%}
