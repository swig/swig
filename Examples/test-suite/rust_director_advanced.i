%module(directors="1") rust_director_advanced

%feature("director") Advanced;

%typemap(rustdirectorin,
         pre="let _swig_director_pre = $iminput;",
         post="let _ = _swig_director_pre;",
         terminator="let _ = 0;") int "$iminput + 1"
%typemap(rustdirectorout) int "$rustcall + 2"

%inline %{

class Advanced {
public:
  Advanced() : last(0) {
  }
  virtual ~Advanced() {
  }
  virtual int transform(int value) {
    return value;
  }
  virtual int overloaded(int value) {
    return value + 10;
  }
  virtual int overloaded(int left, int right) {
    return left + right;
  }
  virtual int pure(int value) = 0;
  virtual void record(int value) {
    last = value;
  }
  virtual int no_throw(int value) {
    return value + 20;
  }
  int call_transform(int value) {
    return transform(value);
  }
  int call_overloaded_one(int value) {
    return overloaded(value);
  }
  int call_overloaded_two(int left, int right) {
    return overloaded(left, right);
  }
  int call_pure(int value) {
    return pure(value);
  }
  void call_record(int value) {
    record(value);
  }
  int call_no_throw(int value) {
    return no_throw(value);
  }
  int get_last() const {
    return last;
  }
private:
  int last;
};

%}
