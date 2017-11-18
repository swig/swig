%module cpp11_shared_ptr_nullptr_in_containers

%{
#include <memory>
#include <vector>

class C;
%}

%include <std_shared_ptr.i>
%include <std_vector.i>

%shared_ptr(C)

%inline %{

class C {
  int m;
public:
  C() : m(-1) {}
  C(int i) : m(i) {}
  int get_m() { return m; }
};

%}

%template() std::vector<std::shared_ptr<C> >;

%inline %{

  std::vector<std::shared_ptr<C> > ret_vec_c_shared_ptr() {
    std::vector<std::shared_ptr<C> > ret(3);
    ret[0] = std::shared_ptr<C>(new C(0));
    ret[2] = std::shared_ptr<C>(new C(2));
    return ret;
  }

  std::vector<std::shared_ptr<C> > ret_arg_vec(const std::vector<std::shared_ptr<C> >& v) {
    return v;
  }

  bool is_last_null(const std::vector<std::shared_ptr<C> >& v) {
    if( v.back() ) {
      return false;
    } else {
      return true;
    }
  }

%}
