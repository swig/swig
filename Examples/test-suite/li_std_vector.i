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

const std::vector<Real> & vecreal(const std::vector<Real> & vec) { return vec; }

const std::vector<int> & vecintptr(const std::vector<int> & vec) { return vec; }
const std::vector<int *> & vecintptr(const std::vector<int *> & vec) { return vec; }
const std::vector<const int *> & vecintconstptr(const std::vector<const int *> & vec) { return vec; }

const std::vector<Struct> & vecstruct(const std::vector<Struct> & vec) { return vec; }
const std::vector<Struct *> & vecstructptr(const std::vector<Struct *> & vec) { return vec; }
const std::vector<const Struct *> & vecstructconstptr(const std::vector<const Struct *> & vec) { return vec; }
%}

#if defined(SWIGCSHARP)
SWIG_STD_VECTOR_SPECIALIZE(Struct, Struct *)
SWIG_STD_VECTOR_SPECIALIZE(Struct, const Struct *)
SWIG_STD_VECTOR_SPECIALIZE(SWIGTYPE_p_int, int *)
SWIG_STD_VECTOR_SPECIALIZE(SWIGTYPE_p_int, const int *)
#endif

%template(IntPtrVector) std::vector<int *>;
%template(IntConstPtrVector) std::vector<const int *>;
%template(StructVector) std::vector<Struct>;
%template(StructPtrVector) std::vector<Struct *>;
%template(StructConstPtrVector) std::vector<const Struct *>;

