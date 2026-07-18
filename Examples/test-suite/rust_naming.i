%module rust_naming

%pragma(rust) methodcase="snake"

%inline %{

int GlobalValue() {
  return 7;
}

class NamingWidget {
public:
  NamingWidget(int value) : value_(value) {
  }
  int GetValue() const {
    return value_;
  }
  void SetValue(int value) {
    value_ = value;
  }
private:
  int value_;
};

%}
