%module li_std_list

%include "std_list.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

namespace std {
    %template(IntList) list<int>;
}

%template(BoolList) std::list<bool>;
%template(CharList) std::list<char>;
%template(ShortList) std::list<short>;
%template(LongList) std::list<long>;
%template(UCharList) std::list<unsigned char>;
%template(UIntList) std::list<unsigned int>;
%template(UShortList) std::list<unsigned short>;
%template(ULongList) std::list<unsigned long>;
%template(DoubleList) std::list<double>;

%inline %{
typedef float Real;
%}

namespace std {
    %template(RealList) list<Real>;
}

%ignore Struct::operator==;

%inline %{

double average(std::list<int> v) {
    return std::accumulate(v.begin(),v.end(),0.0)/v.size();
}


void halve_in_place(std::list<double>& v) {
    std::transform(v.begin(),v.end(),v.begin(),
                   std::bind2nd(std::divides<double>(),2.0));
}

struct Struct {
  double num;
  Struct() : num(0.0) {}
  Struct(double d) : num(d) {}
  bool operator==(const Struct &other) { return (num == other.num); }
};

const std::list<Real> & listreal(const std::list<Real> & list) { return list; }
           
const std::list<int> & listintptr(const std::list<int> & list) { return list; }
const std::list<int *> & listintptr(const std::list<int *> & list) { return list; }
const std::list<const int *> & listintconstptr(const std::list<const int *> & list) { return list; }
           
const std::list<Struct> & liststruct(const std::list<Struct> & list) { return list; }
const std::list<Struct *> & liststructptr(const std::list<Struct *> & list) { return list; }
const std::list<const Struct *> & liststructconstptr(const std::list<const Struct *> & list) { return list; }
%}

#if !defined(SWIGR)
%template(IntPtrList) std::list<int *>;
%template(IntConstPtrList) std::list<const int *>;
#endif
%template(StructList) std::list<Struct>;
%template(StructPtrList) std::list<Struct *>;
%template(StructConstPtrList) std::list<const Struct *>;