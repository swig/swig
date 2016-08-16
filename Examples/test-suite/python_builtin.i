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

