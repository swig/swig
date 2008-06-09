%module samename

#if !(defined(SWIGCSHARP) || defined(SWIGJAVA))
class samename {
 public:
  void do_something() {
    // ...
  }
};
#endif

%{

class samename {
 public:
  void do_something() {
    // ...
  }
};

%}

