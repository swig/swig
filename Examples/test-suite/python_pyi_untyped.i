%module(directors="1") python_pyi_untyped

// Tests -pyi used without -typehints, which generates a stub file carrying no annotations.
// A stub shadows the .py file it accompanies, so it still has to declare everything the module
// exports for a type checker reading it, annotated or not.

%feature("director") Base;

%inline %{
int global_variable = 3;

struct Base {
  virtual ~Base() {}
  virtual int value() const { return 1; }
};
%}
