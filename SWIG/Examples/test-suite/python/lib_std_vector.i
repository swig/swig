%module lib_std_vector

%include "std_vector.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

namespace std {
    %template(IntVector) vector<int>;
    %template(BoolVector) vector<bool>;
}

%template(DoubleVector) std::vector<double>;

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
    virtual void f(const int i) const = 0;
};

struct B : public A {
    void f(const int i) const
    { std::cout << "B::f(int)\n"; }
};
} 
%}
%template(VecB) std::vector<Test::B>; // works
%template(VecA) std::vector<Test::A*>; // Does not work
