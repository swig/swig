%module(directors="1", dirprot="1") rust_director_protected

%feature("director") ProtectedBase;

%inline %{

class ProtectedBase {
public:
  ProtectedBase() {
  }
  virtual ~ProtectedBase() {
  }
  int call_secret(int value) {
    return secret(value);
  }
  int call_plain() {
    return plain();
  }
protected:
  virtual int secret(int value) {
    return value + 1;
  }
  virtual int plain() {
    return 5;
  }
};

%}
