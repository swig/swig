%module class_ignore

%ignore Foo;

%ignore *::Bar::foo;

%inline %{
  class Foo {
  public:
    virtual ~Foo() { }
    virtual char *blah() = 0;
  };
  
  namespace hi 
  {
    namespace hello
    {
      class Bar : public Foo {
      public:
	void foo(void) {};
	
	virtual char *blah() { return (char *) "Bar::blah"; }
      };
    }
  }


  
  char *do_blah(Foo *f) {
    return f->blah();
  }
%}

