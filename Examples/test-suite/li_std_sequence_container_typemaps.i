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

enum _Color { RED=1, GREEN=10, YELLOW=11, BLUE=100, MAGENTA=101, CYAN=111 };
typedef enum _Color Color;

namespace std {
  template<typename T> T binaryOperation(T x, T y) {
    return static_cast<T>(x + y);
  }

  template<> bool binaryOperation(bool x, bool y) {
    return x | y;
  }

  template<> ClassAPtr binaryOperation(ClassAPtr x, ClassAPtr y) {
    if (x)
      y->a += x->a;
    return y;
  }

  template<typename SeqCont>
  struct sequence_container {
    typedef typename SeqCont::value_type value_type;

    static SeqCont ret_container(const value_type value1, const value_type value2) {
      SeqCont s;
      s.push_back(value1);
      s.push_back(value2);
      return s;
    }

    static value_type val_container(const SeqCont container) {
      return std::accumulate(container.begin(), container.end(), value_type(),
        binaryOperation<value_type>);
    }

    static value_type ref_container(const SeqCont& container) {
      return std::accumulate(container.begin(), container.end(), value_type(),
        binaryOperation<value_type>);
    }
  };

  template<typename T>
  std::vector<T> ret_vector(const T value1, const T value2) {
    return sequence_container<std::vector<T> >::ret_container(value1, value2);
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
  std::list<T> ret_list(const T value1, const T value2) {
    return sequence_container<std::list<T> >::ret_container(value1, value2);
  }
  template<typename T>
  T val_list(const std::list<T> container) {
    return sequence_container<std::list<T> >::val_container(container);
  }
  template<typename T>
  T ref_list(const std::list<T>& container) {
    return sequence_container<std::list<T> >::ref_container(container);
  }

  template<typename T>
  std::deque<T> ret_deque(const T value1, const T value2) {
    return sequence_container<std::deque<T> >::ret_container(value1, value2);
  }
  template<typename T>
  T val_deque(const std::deque<T> container) {
    return sequence_container<std::deque<T> >::val_container(container);
  }
  template<typename T>
  T ref_deque(const std::deque<T>& container) {
    return sequence_container<std::deque<T> >::ref_container(container);
  }
}
%}

%define instantiate_containers_templates(TYPE...)
namespace std
{
  %template(TYPE ## _vector) std::vector<TYPE>;
  %template(TYPE ## _list) std::list<TYPE>;
  %template(TYPE ## _deque) std::deque<TYPE>;
}
%enddef

%define instantiate_containers_functions(TYPE...)
namespace std
{
  %template(ret_ ## TYPE ## _vector) ret_vector<TYPE>;
  %template(val_ ## TYPE ## _vector) val_vector<TYPE>;
  %template(ref_ ## TYPE ## _vector) ref_vector<TYPE>;
  %template(ret_ ## TYPE ## _list) ret_list<TYPE>;
  %template(val_ ## TYPE ## _list) val_list<TYPE>;
  %template(ref_ ## TYPE ## _list) ref_list<TYPE>;
  %template(ret_ ## TYPE ## _deque) ret_deque<TYPE>;
  %template(val_ ## TYPE ## _deque) val_deque<TYPE>;
  %template(ref_ ## TYPE ## _deque) ref_deque<TYPE>;
}
%enddef

instantiate_containers_templates(int);
instantiate_containers_templates(double);
instantiate_containers_templates(bool);
instantiate_containers_templates(string);
instantiate_containers_templates(ClassAPtr);

instantiate_containers_functions(int);
instantiate_containers_functions(double);
instantiate_containers_functions(bool);
instantiate_containers_functions(string);
instantiate_containers_functions(ClassAPtr);
