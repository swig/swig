
// This test is to check the intermediary class name can be changed (C# and Java only use intermediary classes at time of writing)
%module(directors="1", jniclassname="intermediary_classname", imclassname="intermediary_classname") "intermediary_classname"

%warnfilter(470,473);

// change the access to the intermediary class for testing purposes
%pragma(java) jniclassclassmodifiers="public class";
%pragma(csharp) imclassclassmodifiers="public class";

%feature("director") Base;
%feature("director") Derived;

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
  void throwspec() throw (int, Base) {}
};
%}

%template(maxint) maximum<int>;
%template(maxdouble) maximum<double>;
%template(vecint) vector<int>;
%template(vecdouble) vector<double>;
%template(maxintp) maximum<int (*)[10]>;
%template(vecintp) vector<int (*)[10]>;


