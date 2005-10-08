%module(ruby_minherit="1") evil_diamond_prop

%warnfilter(801) foo;		// Ruby, wrong class name
%warnfilter(801) bar;		// Ruby, wrong class name
%warnfilter(801) baz;		// Ruby, wrong class name
%warnfilter(801) spam;	        // Ruby, wrong class name
%warnfilter(813,833,870) spam;	// C# & Java, Php4 multiple inheritance

%inline %{

class foo { 
  public:
    int _foo;
    foo() : _foo(1) {}
};

class bar : public foo {
  public:
    int _bar;
    bar() : _bar(2) {}
};

class baz : public foo {
  public:
    int _baz;
    baz() : _baz(3) {}
};

class spam : public bar, public baz {
  public:
    int _spam;
    spam() : _spam(4) {}
};

foo *test(foo *f) { return f; }
%}

