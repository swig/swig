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
  Bar *get_self() {
    return this;
  }
};

// This failed in git pre 4.1.0 with PHP 8.x because we weren't adding the
// prefix to class names in type declarations.  Error was at extension load
// time:
//
// Fatal error: Bar must be registered before ProjectBar in Unknown on line 0
Bar* self(Bar* bar) { return bar->get_self(); }

%}
