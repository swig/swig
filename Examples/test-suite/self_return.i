%module self_return

%inline %{

class Counter {
public:
  Counter(int n = 0) : n(n) {}
  Counter& Inc() {
    ++n;
    return *this;
  }
  Counter& Add(const Counter& other) {
    n += other.n;
    return *this;
  }
  int get_n() const {
    return n;
  }
private:
  int n;
};
%}