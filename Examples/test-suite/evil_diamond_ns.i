%module evil_diamond_ns

%warnfilter(801) Blah::foo;		// Ruby, wrong class name
%warnfilter(801) Blah::bar;		// Ruby, wrong class name
%warnfilter(801) Blah::baz;		// Ruby, wrong class name
%warnfilter(801,802,813) Blah::spam;	// Ruby, wrong class name; Ruby & Java, multiple inheritance

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

