%module(directors="1") objc_director

%feature("director") IntCallback;
%feature("director") BoolCallback;

%inline %{
class IntCallback {
public:
  virtual ~IntCallback() {}
  virtual int run(int value) const { return value + 1; }
};

class BoolCallback {
public:
  virtual ~BoolCallback() {}
  virtual bool run(bool lhs, bool rhs) const = 0;
};

int call_int_callback(const IntCallback &callback, int value) {
  return callback.run(value);
}

bool call_bool_callback(const BoolCallback &callback, bool lhs, bool rhs) {
  return callback.run(lhs, rhs);
}
%}
