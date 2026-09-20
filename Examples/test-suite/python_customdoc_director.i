#ifdef SWIGPYTHON
%module(directors="1") python_customdoc_director
#else
%module python_customdoc_director
#endif

#ifdef SWIGPYTHON
%feature("director");
%feature("customdoc", "1");
%feature("python:customdoc:argtypes", "python_customdoc_director.describe_arguments") Single;
%feature("customdoc:main", "$overview$main");
%feature("customdoc:group", "$group$main");
#endif

%inline %{
struct EmptyConstructor {
  EmptyConstructor() {}
  virtual ~EmptyConstructor() {}
  virtual int method(int self) { return self; }
};
struct Single {
  Single(int value): value(value) {}
  virtual ~Single() {}
  virtual int method() { return value; }
  int value;
};
struct Defaults {
  Defaults(int value = 7): value(value) {}
  virtual ~Defaults() {}
  virtual int method() { return value; }
  int value;
};
struct Multiple {
  Multiple(int value): value(value) {}
  Multiple(double value, int extra): value((int)value + extra) {}
  virtual ~Multiple() {}
  virtual int method() { return value; }
  int value;
};
int invoke(Single *instance) { return instance->method(); }
%}
