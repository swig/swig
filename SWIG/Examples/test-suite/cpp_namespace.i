// C++ namespace tests

%module cpp_namespace

%inline %{

  typedef int Bad;

  /* A very basic namespace */
  namespace example {
    typedef char *Bad;
    int fact(int n) {
      if (n <= 0) return 1;
      else return n*fact(n-1);
    }
    int Foo = 42;

    class Test {
    public:
      Test() { };
      ~Test() { };
      char *method() {
	return (char *) "Test::method";
      }
    };
    typedef Test *TestPtr;

    void weird(Bad x, ::Bad y) { };
  }
  
  char *do_method(example::TestPtr t) {
    return t->method();
  }
%}

      	

