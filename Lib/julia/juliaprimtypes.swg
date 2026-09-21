/* juliaprimtypes.swg
 *
 * Primitive-type SWIG_AsVal / SWIG_From fragments for the -julia target,
 * operating on jl_value_t*.
 */

%include <typemaps/swigmacros.swg>
%include <typemaps/fragments.swg>

%{
#include <julia.h>
#include <cmath>
#include <limits>
#include <type_traits>

/* Match the native integer representation without converting through floating point. */
template <typename T> static jl_value_t *swig_jl_integer_box(T value) {
  return std::is_signed<T>::value ? jl_box_int64(static_cast<int64_t>(value))
                                 : jl_box_uint64(static_cast<uint64_t>(value));
}

template <typename E> static jl_datatype_t *swig_jl_enum_type() {
  typedef typename std::underlying_type<E>::type T;
  static_assert(sizeof(T) <= sizeof(uint64_t), "Julia enums support underlying integers up to 64 bits");
  if (std::is_signed<T>::value) {
    if (sizeof(T) == 1) return jl_int8_type;
    if (sizeof(T) == 2) return jl_int16_type;
    if (sizeof(T) == 4) return jl_int32_type;
    return jl_int64_type;
  }
  if (sizeof(T) == 1) return jl_uint8_type;
  if (sizeof(T) == 2) return jl_uint16_type;
  if (sizeof(T) == 4) return jl_uint32_type;
  return jl_uint64_type;
}

template <typename E> static jl_value_t *swig_jl_enum_box(E value) {
  typedef typename std::underlying_type<E>::type T;
  T native = static_cast<T>(value);
  return jl_new_bits((jl_value_t *)swig_jl_enum_type<E>(), &native);
}

template <typename E> static E swig_jl_enum_read(jl_value_t *value) {
  typedef typename std::underlying_type<E>::type T;
  /* Calling the integer constructor accepts Julia enums and checks the range. */
  jl_value_t *converted = jl_call1((jl_value_t *)swig_jl_enum_type<E>(), value);
  if (jl_exception_occurred()) {
    jl_exception_clear();
    throw std::runtime_error("enum argument is outside its underlying integer range");
  }
  T native;
  memcpy(&native, jl_data_ptr(converted), sizeof(T));
  return static_cast<E>(native);
}

/* Keep integer sources integral: converting through double loses low bits. */
template <typename T> static int swig_jl_asval(jl_value_t *p, T *value) {
  if (!p) return SWIG_ERROR;
  if (jl_typeis(p, jl_int64_type)) {
    int64_t input = jl_unbox_int64(p);
    if (std::is_integral<T>::value) {
      if (std::is_signed<T>::value) {
        if (input < (int64_t)std::numeric_limits<T>::min() ||
            input > (int64_t)std::numeric_limits<T>::max()) return SWIG_ERROR;
      } else if (input < 0 || (uint64_t)input > (uint64_t)std::numeric_limits<T>::max()) {
        return SWIG_ERROR;
      }
    }
    if (value) *value = static_cast<T>(input);
    return SWIG_OK;
  }
  if (jl_typeis(p, jl_bool_type)) {
    if (value) *value = static_cast<T>(jl_unbox_bool(p));
    return SWIG_OK;
  }
  if (!jl_typeis(p, jl_float64_type)) return SWIG_ERROR;
  double input = jl_unbox_float64(p);
  if (std::is_integral<T>::value) {
    double bound = std::ldexp(1.0, std::numeric_limits<T>::digits);
    double lower = std::is_signed<T>::value ? -bound : 0.0;
    if (!std::isfinite(input) || std::trunc(input) != input || input < lower || input >= bound)
      return SWIG_ERROR;
  }
  if (value) *value = static_cast<T>(input);
  return SWIG_OK;
}
%}

%define %julia_primtype_asval(T)
%fragment(SWIG_AsVal_frag(T), "header") {
SWIGINTERN int SWIG_AsVal_dec(T)(jl_value_t *p, T *val) {
  return swig_jl_asval(p, val);
}
}
%enddef

%define %julia_primtype_from_body(T, BOX)
%fragment(SWIG_From_frag(T), "header") {
SWIGINTERNINLINE jl_value_t* SWIG_From_dec(T)(T value) {
  return BOX;
}
}
%enddef

%julia_primtype_asval(bool)
%julia_primtype_asval(int)
%julia_primtype_asval(long)
%julia_primtype_asval(long long)
%julia_primtype_asval(size_t)
%julia_primtype_asval(double)
%julia_primtype_asval(float)

%julia_primtype_from_body(bool, jl_box_bool(value ? 1 : 0))
%julia_primtype_from_body(int, jl_box_int64((int64_t)value))
%julia_primtype_from_body(long, jl_box_int64((int64_t)value))
%julia_primtype_from_body(long long, jl_box_int64((int64_t)value))
%julia_primtype_from_body(size_t, jl_box_int64((int64_t)value))
%julia_primtype_from_body(double, jl_box_float64(value))
%julia_primtype_from_body(float, jl_box_float64((double)value))
