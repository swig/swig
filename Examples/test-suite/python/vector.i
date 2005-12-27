%module vector
%{
#include <vector>
%}

%define SWIG_STD_VECTOR_MINIMUM(CSTYPE, CTYPE...)
  public:
    typedef size_t size_type;
    typedef CTYPE value_type;
    size_type size() const;
    vector();
    %extend {
      static std::vector<CTYPE > *Repeat(const value_type& value, int count) /*throw (std::out_of_range)*/ {
//        if (count < 0)
//          throw std::out_of_range("count");
        return new std::vector<CTYPE >(count, value);
      }
    }
%enddef

namespace std {
  // primary (unspecialized) class template for std::vector
  // does not require operator== to be defined
  template<class T> class vector {
    SWIG_STD_VECTOR_MINIMUM(T, T)
  };
}

%define SWIG_STD_VECTOR_SPECIALIZE(CSTYPE, CTYPE...)
namespace std {
  template<> class vector<CTYPE > {
    SWIG_STD_VECTOR_MINIMUM(CSTYPE, CTYPE)
  };
}
%enddef

SWIG_STD_VECTOR_SPECIALIZE(float, float)

%inline %{
typedef float Real;
%}

#if 1
//fails
namespace std {
    %template(RealVector) vector<int>;
}
#else
//works
%template(RealVector) std::vector<Real>;
#endif 
