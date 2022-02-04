%module samename

%rename("anothername_cls") "anothername";

#if !(defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGD) || defined(SWIGFORTRAN))
/* NOTE: this class has the same name as the module. */
class samename {
 public:
  void do_something() {
    // ...
  }
};

class anothername {
 public:
  void do_something(int samename);
  void do_something_else(int anothername_cls);
};
#endif

%{

class samename {
 public:
  void do_something() {
    // ...
  }
};

class anothername {
 public:
  void do_something(int) {
    // ...
  }
  void do_something_else(int) {
    // ...
  }
};

%}

