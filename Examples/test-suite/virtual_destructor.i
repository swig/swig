/*
This testcase checks that a virtual destructor with void as a parameter is 
correctly handled.
*/

%module virtual_destructor

%inline %{

class VirtualVoidDestructor {
public:
  VirtualVoidDestructor() {};
  virtual ~VirtualVoidDestructor(void) { };
};

%}
