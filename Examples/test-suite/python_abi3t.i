%module python_abi3t

%inline %{
class Abi3tBase1 {
public:
  virtual ~Abi3tBase1() {}
  int base1Value() { return 111; }
};

class Abi3tBase2 {
public:
  virtual ~Abi3tBase2() {}
  int base2Value() { return 222; }
};

class Abi3tFoo : public Abi3tBase1, public Abi3tBase2 {
public:
  Abi3tFoo(int v) : value(v) {}
  int getValue() { return value; }
  int value;
};

int abi3t_global_counter = 7;

typedef int (Abi3tFoo::*Abi3tFooMethodPtr)();
Abi3tFooMethodPtr abi3t_get_getValue_ptr() { return &Abi3tFoo::getValue; }
%}
