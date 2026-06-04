
// This test is to check the intermediary (JNI) class name can be changed (C#, Java and Kotlin
// use intermediary classes). For Kotlin, when the jniclassname/imclassname is set to the module
// name the module object is renamed to <module>Module (backwards compatibility), exactly as in
// the intermediary_classname (Java/C#) testcase.
%module(directors="1", jniclassname="kotlin_intermediary_classname", imclassname="kotlin_intermediary_classname") "kotlin_intermediary_classname"

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR);

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW2(T1, T2) throw(T1, T2)
%{
#define TESTCASE_THROW2(T1, T2)
%}

// change the access to the intermediary class for testing purposes. The Kotlin intermediary
// class must remain a Kotlin "object" (singleton) because the proxy classes access its members
// through the bare class name; only the visibility is changed here (public object).
%pragma(kotlin) jniclassclassmodifiers="public object";
%pragma(java) jniclassclassmodifiers="public class";
%pragma(csharp) imclassclassmodifiers="public class";

%feature("director") Base;
%feature("director") Derived;

// Test the throws attribute in these typemaps. Kotlin has no checked exceptions, so the throws
// attribute is collected but produces no throws clause (unlike Java); the typemap bodies below
// are still exercised.
%typemap(kdirectorout, throws="InstantiationException/*kdirectorout Base&*/") Base&
  "$kotlinclassname.getCPtr($kotlincall)/* XYZ& typemap directorout*/"
%typemap(kdirectorin, throws="ClassNotFoundException/*kdirectorin Base&*/") Base&
  "$kotlinclassname($jniinput, false)/*kdirectorin*/"
%typemap(out, throws="IllegalAccessException/*out Base&*/") Base& {
  // XYZ& typemap out
  $result = 0; // remove unused variable warning
}
%inline %{

template<class T> T maximum(const T a, const T b) { return  a>b ? a : b; }

template<class T> class vector {
  T *v;
  int sz;
 public:
  vector(int _sz) {
    v = new T[_sz];
    sz = _sz;
  }
  T &get(int index) {
    return v[index];
  }
  void set(int index, T &val) {
    v[index] = val;
  }
  void testconst(const T x) { }
};

class Base {
public:
  Base() : mVectInt(0) {}
  Base(Base *b) : mVectInt(0) {}
  virtual ~Base() {}
  virtual Base& m1(Base &b) { return b; }
  virtual Base& m1out() { static Base b; return b; }
  virtual Base* m2(Base *b) { return b; }
//  virtual Base m3(Base b) { return b; }
  vector<int> mVectInt;
  int mInt;
  enum en { en1, en2 };
  en enummethod(en e) { return e; }
};
class Derived : public Base {
public:
  Derived(Base *b) : Base(b) {}
  virtual Base& m1(Base &b) { return b; }
  virtual Base* m2(Base *b) { return b; }
//  virtual Base m3(Base b) { return b; }
  void throwspec() TESTCASE_THROW2(int, Base) {}
};
%}

%template(maxint) maximum<int>;
%template(maxdouble) maximum<double>;
%template(vecint) vector<int>;
%template(vecdouble) vector<double>;
%template(maxintp) maximum<int (*)[10]>;
%template(vecintp) vector<int (*)[10]>;
