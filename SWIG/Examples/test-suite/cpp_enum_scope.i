%module cpp_enum_scope

// This tests to make sure default arguments are handled correctly
// when scoped.

%inline %{
enum flavor { BITTER, SWEET };

class Foo {
public:
   enum speed { FAST, SLOW };

   // Note: default values should be Foo::FAST and SWEET 
   void blah(speed s = FAST, flavor f = SWEET) {};
};

%}
