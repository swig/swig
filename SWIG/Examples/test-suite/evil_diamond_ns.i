%module evil_diamond_ns

%inline %{
namespace Blah {
class foo { };

class bar : public foo {
};

class baz : public foo {
};

class spam : public bar, public baz {
};

foo *test(foo *f) { return f; }
}
%}

