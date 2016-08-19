// Test customizing slots when using the -builtin option

%module python_builtin

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

// Test 1 for tp_hash
#if defined(SWIGPYTHON_BUILTIN)
%feature("python:tp_hash") SimpleValue "SimpleValueHashFunction"
#endif

%inline %{
struct SimpleValue {
  int value;
  SimpleValue(int value) : value(value) {}
  static SimpleValue *inout(SimpleValue *sv) {
    return sv;
  }
};
%}

%{
#if PY_VERSION_HEX >= 0x03020000
Py_hash_t SimpleValueHashFunction(PyObject *v)
#else
long SimpleValueHashFunction(PyObject *v)
#endif
{
  SwigPyObject *sobj = (SwigPyObject *) v;
  SimpleValue *p = (SimpleValue *)sobj->ptr;
  return p->value;
}
hashfunc test_hashfunc_cast() {
    return SimpleValueHashFunction;
}
%}

// Test 2 for tp_hash
#if defined(SWIGPYTHON_BUILTIN)
%feature("python:slot", "tp_hash", functype="hashfunc") BadHashFunctionReturnType::bad_hash_function;
#endif

%inline %{
struct BadHashFunctionReturnType {
    static const char * bad_hash_function() {
      return "bad hash function";
    }
};
%}

// Test 3 for tp_hash
#if defined(SWIGPYTHON_BUILTIN)
%feature("python:slot", "tp_hash", functype="hashfunc") ExceptionHashFunction::exception_hash_function;
#endif

%catches(const char *) exception_hash_function;

%inline %{
#if PY_VERSION_HEX < 0x03020000
  #define Py_hash_t long
#endif
struct ExceptionHashFunction {
    static Py_hash_t exception_hash_function() {
      throw "oops";
    }
};
%}

// Test 4 for tp_dealloc (which is handled differently to other slots in the SWIG source)
#if defined(SWIGPYTHON_BUILTIN)
%feature("python:tp_dealloc") Dealloc1 "Dealloc1Destroyer"
%feature("python:tp_dealloc") Dealloc2 "Dealloc2Destroyer"
%feature("python:slot", "tp_dealloc", functype="destructor") Dealloc3::Destroyer;
#endif

%inline %{
static int Dealloc1CalledCount = 0;
static int Dealloc2CalledCount = 0;
static int Dealloc3CalledCount = 0;

struct Dealloc1 {
};
struct Dealloc2 {
  ~Dealloc2() {}
};
struct Dealloc3 {
  void Destroyer() {
    Dealloc3CalledCount++;
    delete this;
  }
};
%}

%{
void Dealloc1Destroyer(PyObject *v) {
  SwigPyObject *sobj = (SwigPyObject *) v;
  Dealloc1 *p = (Dealloc1 *)sobj->ptr;
  delete p;
  Dealloc1CalledCount++;
}
void Dealloc2Destroyer(PyObject *v) {
  SwigPyObject *sobj = (SwigPyObject *) v;
  Dealloc2 *p = (Dealloc2 *)sobj->ptr;
  delete p;
  Dealloc2CalledCount++;
}
%}

