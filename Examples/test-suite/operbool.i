%module operbool

%inline %{
  class Test {
  public:
    operator bool() {
      return false;
    }
  };
%}
