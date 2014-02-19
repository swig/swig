%module li_std_sequence_container_typemaps

%include stl.i

%{
#include <vector>
#include <list>
#include <deque>
#include <iostream>
#include <iterator>
#include <algorithm>
#include <numeric>
%}

%inline %{
class ClassA
{
public:
  ClassA() : a(0) {}
  ClassA(int _a) : a(_a) {}
  ClassA(const ClassA& c) : a(c.a) {}
  int a;
};

typedef ClassA* ClassAPtr;

namespace std {
  template<typename T> T binaryOperation(T x, T y) {
    return x + y;
  }

  template<> bool binaryOperation(bool x, bool y) {
    return x | y;
  }

  template<> ClassAPtr binaryOperation(ClassAPtr x, ClassAPtr y) {
    x->a += y->a;
    return x;
  }

  template<typename SeqCont>
  struct sequence_container {
    typedef typename SeqCont::value_type value_type;

    static SeqCont ret_container(const int size, const value_type value) {
      return SeqCont(size, value);
    }

    static value_type val_container(const SeqCont container) {
      return std::accumulate(container.begin(), container.end(), container.front(),
        binaryOperation<value_type>);
    }

    static value_type ref_container(const SeqCont& container) {
      return std::accumulate(container.begin(), container.end(), container.front(),
        binaryOperation<value_type>);
    }

    /*SeqCont ret_val_containers(const SeqCont container,
      const SeqCont other_container) {
      SeqCont out_container(container);
      out_container.insert(out_container.end(), other_container.begin(),
        other_container.end());
      return out_container;
    }*/
  };

  template<typename T>
  std::vector<T> ret_vector(const int size, const T value) {
    return sequence_container<std::vector<T> >::ret_container(size, value);
  }
  template<typename T>
  T val_vector(const std::vector<T> container) {
      return sequence_container<std::vector<T> >::val_container(container);
  }
  template<typename T>
  T ref_vector(const std::vector<T>& container) {
      return sequence_container<std::vector<T> >::ref_container(container);
  }

  template<typename T>
  std::list<T> ret_list(const int size, const T value) {
    return sequence_container<std::list<T> >::ret_container(size, value);
  }
  template<typename T>
  T val_list(const std::list<T> container) {
      return sequence_container<std::list<T> >::val_container(container);
  }
  template<typename T>
  T ref_list(const std::list<T>& container) {
      return sequence_container<std::list<T> >::ref_container(container);
  }
}
%}

%define instantiate_containers_templates(TYPE...)
namespace std
{
  %template(TYPE ##_## vector) std::vector<TYPE >;
  %template(ret_ ## TYPE ##_## vector) ret_vector<TYPE>;
  %template(val_ ## TYPE ##_## vector) val_vector<TYPE>;
  %template(ref_ ## TYPE ##_## vector) ref_vector<TYPE>;

  %template(TYPE ##_## list) std::list<TYPE >;
  %template(ret_ ## TYPE ##_## list) ret_list<TYPE>;
  %template(val_ ## TYPE ##_## list) val_list<TYPE>;
  %template(ref_ ## TYPE ##_## list) ref_list<TYPE>;
}
%enddef


instantiate_containers_templates(int)
instantiate_containers_templates(double)
instantiate_containers_templates(bool)
instantiate_containers_templates(string)
instantiate_containers_templates(ClassAPtr)


