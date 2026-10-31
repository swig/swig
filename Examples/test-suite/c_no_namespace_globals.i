%module c_no_namespace_globals

// Run without -namespace, which gives the C accessor functions of the global variables no prefix
%inline %{
struct Counter {
  int count;
  Counter() : count(0) {}
};

Counter counter;

namespace space {
  int twice(int i) {
    return 2 * i;
  }

  int number = 1;
  int (*operation)(int) = twice;
}
%}
