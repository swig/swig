%module profiletest

%inline %{

  class A  {
  public:
    A() {}
  };

  class B
  { 
    A aa;
  public: 
    B() {} 
    A fn(const A* a) {
      return *a;
    }

    int fi(int a) {
      return a;
    }

    int fj(const A* a) {
      return 10;
    }

    B* fk(int i) {
      return this;
    }

    const char* fl(int i) {
      return "hello";
    }
  };

%}
