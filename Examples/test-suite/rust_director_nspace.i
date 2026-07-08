%module(directors="1") rust_director_nspace

%nspace;
%feature("director") outer::NamespacedReceiver;

%inline %{

namespace outer {

class NamespacedReceiver {
public:
  NamespacedReceiver() {
  }
  virtual ~NamespacedReceiver() {
  }
  virtual int receive(int value) {
    return value;
  }
  int call_receive(int value) {
    return receive(value);
  }
};

}

%}
