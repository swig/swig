// Tests if exception handling still works in the presence of a wrapped C++
// class called »Exception«, which could shadow the built-in Exception class.
%module d_exception_name

%inline %{
  class Exception {
    Exception(int i) {}
  };

  class Foo {
    ~Foo() {}
  public:
    void bar(Exception *e) {}
  };
%}
