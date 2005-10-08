%module(ruby_minherit="1") evil_diamond_ns

%warnfilter(801) Blah::foo;		// Ruby, wrong class name
%warnfilter(801) Blah::bar;		// Ruby, wrong class name
%warnfilter(801) Blah::baz;		// Ruby, wrong class name
%warnfilter(801) Blah::spam;	        // Ruby, wrong class name
%warnfilter(813,833,870) Blah::spam;	// C# & Java, Php4 multiple inheritance

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

