%module li_std_except

%include <std_except.i>


%inline %{
  struct E1 : public std::exception
  {
  };

  struct E2 
  {
  };

  struct Test {
    int foo1() throw(std::bad_exception) { return 0; }
    int foo2() throw(std::logic_error) { return 0; }
    int foo3() throw(E1) { return 0; }
    int foo4() throw(E2) { return 0; }
  };
%}
