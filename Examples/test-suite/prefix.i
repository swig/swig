// Test that was failing for PHP - the value of the -prefix option was
// ignored
%module prefix

%inline %{

class Foo {
public:
  Foo *get_self() {
    return this;
  }
};

// This failed in git pre 4.1.0 - the calls to the parent class' magic __get,
// __set and __isset methods weren't getting the prefix.
class Bar : public Foo {
public:
};

%}
