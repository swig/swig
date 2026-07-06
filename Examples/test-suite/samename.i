%module samename

#if !(defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGD) || defined(SWIGKOTLIN))
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

