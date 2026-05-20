%module template_land_op

%include "std_vector.i"

%template(VecInt) std::vector<int>;

// Basic: idcolon && idcolon in template argument
template<typename T>
struct EnableIf;

template<typename T>
struct IsIntegral {
  enum { value = 1 };
};

template<typename T>
struct IsSigned {
  enum { value = 1 };
};

template<typename T, bool = EnableIf<IsIntegral<T>::value && IsSigned<T>::value>::value>
struct check_land;

// Chained: idcolon && idcolon && idcolon
template<typename T, bool = EnableIf<IsIntegral<T>::value && IsSigned<T>::value && true>::value>
struct check_land_chain;

// Single: idcolon && value
template<typename T, bool = EnableIf<IsIntegral<T>::value && true>::value>
struct check_land_single;

// idcolon & idcolon (bitwise AND)
template<typename T, bool = EnableIf<IsIntegral<T>::value & IsSigned<T>::value>::value>
struct check_band;

// Mixed: idcolon && (idcolon && idcolon)
template<typename T, bool = EnableIf<IsIntegral<T>::value && (IsIntegral<T>::value && IsSigned<T>::value)>::value>
struct check_land_paren;
