%module(directors="1") cpp11_rust_director_noexcept

%feature("director") NoexceptReceiver;

%inline %{
class NoexceptReceiver {
public:
  virtual ~NoexceptReceiver() {
  }
  virtual int no_throw(int value) noexcept {
    return value + 1;
  }
  int call_no_throw(int value) noexcept {
    return no_throw(value);
  }
};
%}
