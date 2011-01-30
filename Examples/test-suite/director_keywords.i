// Checks if collisions of argument names with target language keywords are
// resolved properly when directors are used (currently only »abstract« for
// C#, D and Java is checked).
%module(directors="1") director_keywords

%feature("director") Foo;

%inline %{
struct Foo {
  virtual ~Foo() {}
  virtual void bar(int abstract) {}
};
%}
