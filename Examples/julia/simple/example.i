%module example
%inline %{
class Counter {
public:
  Counter(int value = 0) : value_(value) {}
  int increment(int amount = 1) { return value_ += amount; }
private:
  int value_;
};
%}
