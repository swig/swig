%module li_std_vector

%include "std_vector.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

namespace std {
    %template(IntVector) vector<int>;
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

struct Struct {
  double num;
  Struct() : num(0.0) {}
  Struct(double d) : num(d) {}
//  bool operator==(const Struct &other) { return (num == other.num); }
};
%}

#ifndef SWIGCSHARP
// Can't do vectors of pointers yet
%template(IntPtrVector) std::vector<int *>;
#endif

%template(StructVector) std::vector<Struct>;


