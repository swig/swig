%module(ruby_minherit="1") evil_diamond

%warnfilter(801) foo;		// Ruby, wrong class name
%warnfilter(801) bar;		// Ruby, wrong class name
%warnfilter(801) baz;		// Ruby, wrong class name
%warnfilter(801) spam;	        // Ruby, wrong class name
%warnfilter(813,833,870) spam;	// C# & Java, Php4 multiple inheritance

%inline %{

class foo { };

class bar : public foo {
};

class baz : public foo {
};

class spam : public bar, public baz {
};

foo *test(foo *f) { return f; }
%}

