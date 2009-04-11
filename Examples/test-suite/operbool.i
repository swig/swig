%module operbool

%rename(operbool) operator bool();

%inline %{
  class Test {
  public:
    operator bool() {
      return false;
    }
  };
%}
