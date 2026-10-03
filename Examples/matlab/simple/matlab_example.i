%module matlab_example
%inline %{
int add(int a, int b) {
  return a + b;
}
class Counter {
public:
  Counter(int initial = 0) : value(initial) {}
  int increment() { return ++value; }
  int value;
};
%}
