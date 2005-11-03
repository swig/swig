%module li_std_vector

%include "std_string.i"
%include "std_vector.i"
%include "cpointer.i"
%include "carrays.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

namespace std {
    %template() vector<short>;
    %template(IntVector) vector<int>;
    %template(BoolVector) vector<bool>;
    %template() vector<string>;
}

%template(DoubleVector) std::vector<double>;


%template(sizeVector) std::vector<size_t>;
%{
  template <class T>
  struct Param
  {
    T val;

    Param(T v = 0): val(v) {
    }
    
    operator T() const { return val; }
  };
%}
specialize_std_vector(Param<int>,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
%template(PIntVector) std::vector<Param<int> >;

%inline %{
typedef float Real;
%}

namespace std {
    %template(RealVector) vector<Real>;
}

%inline %{

double average(std::vector<int> v) {
    return std::accumulate(v.begin(),v.end(),0.0)/v.size();
}

std::vector<Real> half(const std::vector<Real>& v) {
    std::vector<Real> w(v);
    for (std::vector<Real>::size_type i=0; i<w.size(); i++)
        w[i] /= 2.0;
    return w;
}

void halve_in_place(std::vector<double>& v) {
    std::transform(v.begin(),v.end(),v.begin(),
                   std::bind2nd(std::divides<double>(),2.0));
}

%}

%template(IntPtrVector) std::vector<int *>;



//
//
%{
#include <iostream>
%}

%inline %{
  
namespace Test {
struct A {
    virtual ~A() {}    
    virtual int f(const int i) const = 0;
};

struct B : public A {
  int val;
  
  B(int i = 0) : val(i)
  {
  }
  
  int f(const int i) const { return i + val; }
};


int vecAptr(const std::vector<A*>& v) {
    return v[0]->f(1);
}

} 

std::vector<short> halfs(const std::vector<short>& v) {
    std::vector<short> w(v);
    for (std::vector<short>::size_type i=0; i<w.size(); i++)
        w[i] /= 2;
    return w;
}


std::vector<std::string>  vecStr(std::vector<std::string> v) {
  v[0] += v[1];
  return v;
}

%}
%template(VecB) std::vector<Test::B>; 
%template(VecA) std::vector<Test::A*>; 

%pointer_class(int,PtrInt)
%array_functions(int,ArrInt)


%template(pyvector) std::vector<swig::PyItem>; 
