%module lib_std_vector

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

std::vector<float> half(const std::vector<float>& v) {
    std::vector<float> w(v);
    for (unsigned int i=0; i<w.size(); i++)
        w[i] /= 2.0;
    return w;
}

void halve_in_place(std::vector<double>& v) {
    std::transform(v.begin(),v.end(),v.begin(),
                   std::bind2nd(std::divides<double>(),2.0));
}

%}




