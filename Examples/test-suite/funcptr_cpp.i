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
int callref3(int * (&d)(const int &, int), int a, int b) { return *d(a, b); }
int * (&getAddByPointerRef())(const int &, int) { return addByPointer; }
struct AddByValueRefHolder {
  AddByValueTypedef &fnRef;
  AddByValueRefHolder(AddByValueTypedef &f) : fnRef(f) {}
  int call(int a, int b) { return fnRef(a, b); }
};

// Const member functions returning a pointer or reference to a function
struct AddByValueGetter {
  int (*getPtr() const)(const int &, int) { return addByValue; }
  int (&getRef() const)(const int &, int) { return addByValue; }
};

// Reference to a pointer to a function as a parameter or return type
int callptrref1(int (*&d)(const int &, int), int a, int b) { return d(a, b); }
int callptrref2(int (* const &d)(const int &, int), int a, int b) { return d(a, b); }
int callptrref3(int * (*&d)(const int &, int), int a, int b) { return *d(a, b); }
int (*&getAddByValuePtrRef())(const int &, int) { static int (*ptr)(const int &, int) = addByValue; return ptr; }

// Function pointers with a typedef parameter returning an enum in a namespace or a pointer to a class
namespace FuncPtrScope {
  enum Colour { Red, Green };
}
typedef int ColourIndex;
FuncPtrScope::Colour colourOf(int i) { return i ? FuncPtrScope::Green : FuncPtrScope::Red; }
FuncPtrScope::Colour (*getColourFn())(int) { return colourOf; }
FuncPtrScope::Colour callColourFn(FuncPtrScope::Colour (*fn)(ColourIndex), ColourIndex i) { return fn(i); }
struct ColourHolder {
  int index;
};
ColourHolder *holderOf(int i) { static ColourHolder holder; holder.index = i; return &holder; }
ColourHolder *(*getHolderFn())(int) { return holderOf; }
int callHolderFn(ColourHolder *(*fn)(ColourIndex), ColourIndex i) { return fn(i)->index; }
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

// Reference to a pointer to an array as a parameter
int arrayPtrRefSum(int (*&a)[4]) { return arrayRefSum(a); }
%}

%ignore NotWrapped;

%inline %{
// Function pointers using a class that is not wrapped
struct NotWrapped {
  int value;
};
NotWrapped *getNotWrapped() { static NotWrapped notWrapped = { 42 }; return &notWrapped; }
int notWrappedValue(NotWrapped *p) { return p->value; }
int callNotWrappedFn(int (*fn)(NotWrapped *), NotWrapped *p) { return fn(p); }
%}

%constant int (*NOT_WRAPPED_VALUE)(NotWrapped *) = notWrappedValue;

%{
bool notBool(bool b) { return !b; }
%}

%constant bool (*NOT_BOOL)(bool) = notBool;

%inline %{
// Function pointer using bool, which no other declaration here uses
int callBoolFn(bool (*fn)(bool), int i) { return fn(i != 0) ? 1 : 0; }
%}

// Typemaps for a function pointer, named or not, followed by locals, which are not part of the pattern
%typemap(in, numinputs=0) int (*localsFn)(int) (int (*temp)(int)) %{
  temp = localsAddOne;
  $1 = temp;
%}
%typemap(in, numinputs=0) int (*)(int, int) (int (*temp)(int, int)) %{
  temp = localsAdd;
  $1 = temp;
%}

%inline %{
int localsAddOne(int a) { return a + 1; }
int localsAdd(int a, int b) { return a + b; }
int callLocalsNamed(int (*localsFn)(int), int a) { return localsFn(a); }
int callLocalsUnnamed(int (*fn)(int, int), int a, int b) { return fn(a, b); }
%}
