%module functors

// Rename operator() only if the language does not already do this by default
#if defined(SWIGCSHARP) || defined(SWIGGO) || defined(SWIGGUILE) || defined(SWIGJAVA) || defined(SWIGJAVASCRIPT) || defined(SWIGPHP) || defined(SWIGSCILAB) || defined(SWIGTCL)
%rename(Funktor) operator();
#endif

%inline %{
class Functor0 {
  int num;
public:
  Functor0(int num) : num(num) {}
  int operator()() { return -num; }
  int operate() { return this->operator()(); }
};

class Functor1 {
  int num;
public:
  Functor1(int num) : num(num) {}
  int operator()(int x) { return num + x; }
  int operate(int x) { return this->operator()(x); }
};

class Functor2 {
  int num;
public:
  Functor2(int num) : num(num) {}
  int operator()(int x, int x2) { return num + x + x2; }
  int operate(int x, int x2) { return this->operator()(x, x2); }
};
%}

