%module add_link

%addmethods Foo {
Foo *blah() {
   return new Foo();
}
};


%inline %{
class Foo {
public:
  Foo() { };
};

%}


