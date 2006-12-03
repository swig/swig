%module li_std_vector

%include "std_vector.i"
%include "std_string.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

namespace std {
    %template(IntVector) vector<int>;
}

%template(BoolVector) std::vector<bool>;
%template(CharVector) std::vector<char>;
%template(ShortVector) std::vector<short>;
%template(LongVector) std::vector<long>;
%template(UCharVector) std::vector<unsigned char>;
%template(UIntVector) std::vector<unsigned int>;
%template(UShortVector) std::vector<unsigned short>;
%template(ULongVector) std::vector<unsigned long>;
%template(DoubleVector) std::vector<double>;
%template(StringVector) std::vector<std::string>;


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
};

struct Structure {
  double num;
  Structure() : num(0.0) {}
  Structure(double d) : num(d) {}
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

// Also test non-specialized versions
%template(StructurePtrVector) std::vector<Structure *>;
%template(StructureConstPtrVector) std::vector<const Structure *>;
#endif

%template(IntPtrVector) std::vector<int *>;
%template(IntConstPtrVector) std::vector<const int *>;
%template(StructVector) std::vector<Struct>;
%template(StructPtrVector) std::vector<Struct *>;
%template(StructConstPtrVector) std::vector<const Struct *>;

#if defined(SWIGCSHARP)
SWIG_STD_VECTOR_SPECIALIZE(MyClass, MyClass *)
#endif

#if !defined(SWIGTCL)
%inline {
  struct MyClass {};
  typedef MyClass *MyClassPtr;
  typedef std::vector<MyClassPtr> MyClassVector;
}
%template(MyClassPtrVector) std::vector<MyClassPtr>;

%inline {
  class RetsMetadata
  {
  public:
    MyClassVector GetAllResources(size_t n) const
    {
      return MyClassVector(n, 0);
    }
  };
}
#endif
