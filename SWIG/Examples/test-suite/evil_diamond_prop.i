%module evil_diamond_prop

%warnfilter(801) foo;		// Ruby, wrong class name
%warnfilter(801) bar;		// Ruby, wrong class name
%warnfilter(801) baz;		// Ruby, wrong class name
%warnfilter(801,802,813) spam;	// Ruby, wrong class name; Ruby & Java, multiple inheritance

%inline %{

class foo { 
  public:
    int _foo;
};

class bar : public foo {
  public:
    int _bar;
};

class baz : public foo {
  public:
    int _baz;
};

class spam : public bar, public baz {
  public:
    int _spam;
};

foo *test(foo *f) { return f; }
%}

