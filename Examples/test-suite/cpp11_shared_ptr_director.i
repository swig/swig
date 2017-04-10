%module(directors="1") "cpp11_shared_ptr_director"

%{
#include <memory>
%}

%include "std_shared_ptr.i";
%shared_ptr(Created);
%feature("director") Creator;

%inline %{
struct Created {};

struct Creator {
  Creator() {};
  virtual std::shared_ptr<Created> create() = 0;
  virtual ~Creator() {}
};

void crash(Creator* creator) {
  std::shared_ptr<Created> ptr = creator->create();
}
%}
