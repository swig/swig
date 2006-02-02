// Test the allowexcept feature by making the usual $action uncompileable and ensuring the %exception is picked up

%module allowexcept

struct XYZ {
};

%{
struct XYZ {
  void foo() {}
private:
  XYZ& operator=(const XYZ& other); // prevent assignment used in normally generated set method
  XYZ* operator&(); // prevent dereferencing used in normally generated  get method
};
%}

%exception {
  /* 
   $action
  */
}
%allowexception;

%inline %{
XYZ global_variable;
struct Foo {
  XYZ member_variable;
  static XYZ static_member_variable;
};
%}

