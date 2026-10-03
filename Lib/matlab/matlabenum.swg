/* Ordinary C enums retain the shared integer typemaps. */
#ifdef __cplusplus
%fragment("SWIG_Matlab_Enum", "header") {
%#include <cmath>
%#include <limits>
%#if __cplusplus >= 201103L
%#include <type_traits>
%#endif

template <class T> struct SWIG_Matlab_Enum {
%#if __cplusplus >= 201103L
  typedef typename std::underlying_type<T>::type underlying_type;
  static_assert(sizeof(underlying_type) <= sizeof(uint64_T), "MATLAB supports enum underlying types up to 64 bits");
%#else
  typedef int underlying_type;
%#endif
  static int asval(mxArray *input, volatile T *result) {
    int64_T signed_value = 0;
    uint64_T unsigned_value = 0;
    bool is_unsigned = false;
    if (!input || mxGetNumberOfElements(input) != 1 || mxIsComplex(input) || mxIsSparse(input))
      return SWIG_TypeError;
    switch (mxGetClassID(input)) {
    case mxINT8_CLASS: signed_value = *(int8_T *)mxGetData(input); break;
    case mxUINT8_CLASS: unsigned_value = *(uint8_T *)mxGetData(input); is_unsigned = true; break;
    case mxINT16_CLASS: signed_value = *(int16_T *)mxGetData(input); break;
    case mxUINT16_CLASS: unsigned_value = *(uint16_T *)mxGetData(input); is_unsigned = true; break;
    case mxINT32_CLASS: signed_value = *(int32_T *)mxGetData(input); break;
    case mxUINT32_CLASS: unsigned_value = *(uint32_T *)mxGetData(input); is_unsigned = true; break;
    case mxINT64_CLASS: signed_value = *(int64_T *)mxGetData(input); break;
    case mxUINT64_CLASS: unsigned_value = *(uint64_T *)mxGetData(input); is_unsigned = true; break;
    case mxDOUBLE_CLASS:
    case mxSINGLE_CLASS: {
      double value = mxGetScalar(input);
      double bound = std::ldexp(1.0, std::numeric_limits<underlying_type>::digits);
      if (value != std::floor(value)) return SWIG_TypeError;
      if (value < (std::numeric_limits<underlying_type>::is_signed ? -bound : 0.0) || value >= bound)
        return SWIG_OverflowError;
      if (result) *result = static_cast<T>(static_cast<underlying_type>(value));
      return SWIG_OK;
    }
    default: return SWIG_TypeError;
    }
    if (is_unsigned) {
      if (unsigned_value > static_cast<uint64_T>((std::numeric_limits<underlying_type>::max)()))
        return SWIG_OverflowError;
      if (result) *result = static_cast<T>(static_cast<underlying_type>(unsigned_value));
    } else {
      if (std::numeric_limits<underlying_type>::is_signed) {
        if (signed_value < static_cast<int64_T>((std::numeric_limits<underlying_type>::min)()) ||
            signed_value > static_cast<int64_T>((std::numeric_limits<underlying_type>::max)()))
          return SWIG_OverflowError;
      } else if (signed_value < 0 || static_cast<uint64_T>(signed_value) > static_cast<uint64_T>((std::numeric_limits<underlying_type>::max)())) {
        return SWIG_OverflowError;
      }
      if (result) *result = static_cast<T>(static_cast<underlying_type>(signed_value));
    }
    return SWIG_OK;
  }
  static mxArray *from(T value) {
    if (std::numeric_limits<underlying_type>::is_signed) {
      mxArray *result = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
      *static_cast<int64_T *>(mxGetData(result)) = static_cast<int64_T>(value);
      return result;
    }
    mxArray *result = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *static_cast<uint64_T *>(mxGetData(result)) = static_cast<uint64_T>(value);
    return result;
  }
};
/* Typedefs may retain cv qualifiers even when wrapper storage is unqualified. */
template <class T> struct SWIG_Matlab_Enum<const T> : SWIG_Matlab_Enum<T> {};
template <class T> struct SWIG_Matlab_Enum<volatile T> : SWIG_Matlab_Enum<T> {};
template <class T> struct SWIG_Matlab_Enum<const volatile T> : SWIG_Matlab_Enum<T> {};

template <class T> int SWIG_Matlab_AsEnum(mxArray *input, T *value) {
  return SWIG_Matlab_Enum<T>::asval(input, value);
}
%#if __cplusplus >= 201103L
template <class T> mxArray *SWIG_Matlab_FromEnum(T value) {
  return SWIG_Matlab_Enum<T>::from(value);
}
%#else
/* C++98 does not allow unnamed enum types as template arguments. */
SWIGINTERN mxArray *SWIG_Matlab_FromEnum(int value) {
  return SWIG_Matlab_Enum<int>::from(value);
}
%#endif
}

%typemap(in, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  int result = SWIG_Matlab_Enum< $basetype >::asval($input, &$1);
  if (!SWIG_IsOK(result)) {
    %argument_fail(result, "$type", $symname, $argnum);
  }
}
%typemap(in, fragment="SWIG_Matlab_Enum") const enum SWIGTYPE & ($basetype temporary) {
  int result = SWIG_Matlab_Enum< $basetype >::asval($input, &temporary);
  if (!SWIG_IsOK(result)) {
    %argument_fail(result, "$type", $symname, $argnum);
  }
  $1 = &temporary;
}
%typemap(out, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  %set_output(SWIG_Matlab_Enum< $basetype >::from($1));
}
%typemap(out, fragment="SWIG_Matlab_Enum") const enum SWIGTYPE & {
  %set_output(SWIG_Matlab_Enum< $basetype >::from(*$1));
}
%typemap(varin, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
%#if __cplusplus >= 201103L
  int result = SWIG_Matlab_AsEnum($input, &$1);
  if (!SWIG_IsOK(result)) {
    %variable_fail(result, "$type", "$name");
  }
%#else
  /* Anonymous enum types cannot be template arguments in C++98. */
  int value;
  int result = SWIG_Matlab_Enum<int>::asval($input, &value);
  if (sizeof($1) != sizeof(value)) {
    %variable_fail(SWIG_AttributeError, "$type", "arch, read-only $name");
  }
  if (!SWIG_IsOK(result)) {
    %variable_fail(result, "$type", "$name");
  }
  memcpy(&$1, &value, sizeof(value));
%#endif
}
%typemap(varout, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  %set_varoutput(SWIG_Matlab_FromEnum($1));
}
%typemap(constcode, noblock=1, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  %set_constant("$symname", SWIG_Matlab_FromEnum($value));
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_INT32, fragment="SWIG_Matlab_Enum") enum SWIGTYPE, const enum SWIGTYPE & {
  $1 = SWIG_IsOK(SWIG_Matlab_Enum< $basetype >::asval($input, 0));
}
%typemap(directorin, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  $input = SWIG_Matlab_Enum< $basetype >::from($1);
}
%typemap(directorin, fragment="SWIG_Matlab_Enum") const enum SWIGTYPE & {
  $input = SWIG_Matlab_Enum< $basetype >::from($1);
}
%typemap(directorout, fragment="SWIG_Matlab_Enum") enum SWIGTYPE {
  int swig_enum_status = SWIG_Matlab_Enum< $basetype >::asval($input, &$result);
  if (!SWIG_IsOK(swig_enum_status)) {
    %dirout_fail(swig_enum_status, "$type");
  }
}
%apply const enum SWIGTYPE & { const enum SWIGTYPE && };
#endif
