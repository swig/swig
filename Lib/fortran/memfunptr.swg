/* -------------------------------------------------------------------------
 * memfunptr.swg
 * ------------------------------------------------------------------------- */

/* The size of the opaque object that stores the member function pointer.
 *
 * This could be overridden by generating a config.h file with the actual
 * maximum function pointer size and %include-ing that configure file in
 * a local fortranfragments.swg file. */
#ifndef SWIG_MEMFUNPTR_SIZE
%define SWIG_MEMFUNPTR_SIZE 32 %enddef
#endif

/* -------------------------------------------------------------------------
 * BRUTE CAST
 * ------------------------------------------------------------------------- */

// This fragment allows making an opaque datatype from C++ member function
// pointers (which according to the standard CANNOT be converted to a pointer).
// encountered. Its syntax is exactly like static_cast.
// Note that the <string.h> fragment imports size_t into the global namespace.
%fragment("swig::brute_cast", "header", fragment="<string.h>") %{
template<typename Dst, typename Src>
SWIGINTERN void SWIG_opaque_memcpy(Dst *dst, const Src *src) {
  const size_t MINSIZE
    = (sizeof(Dst) < sizeof(Src) ? sizeof(Dst) : sizeof(Src));
  const size_t MAXSIZE
    = (sizeof(Dst) > sizeof(Src) ? sizeof(Dst) : sizeof(Src));
  memcpy(dst, src, MINSIZE);
  if (MAXSIZE > MINSIZE)
  {
    memset(static_cast<char*>(static_cast<void*>(dst)) + MINSIZE,
                MAXSIZE - MINSIZE,
                0);
  }
}

namespace swig {
template<typename Target>
class brute_cast_impl {
 public:
  template<typename Source>
    brute_cast_impl(const Source &src_fwd) {
      SWIG_opaque_memcpy(&d_result, &src_fwd);
    }
  Target operator() () const { return d_result; }
 private:
  Target d_result;
};

template<typename Target>
class brute_cast_impl<Target&> {
 public:
  template<typename Source>
    brute_cast_impl(Source& src_ref) {
      Source *src_ptr = &src_ref;
      SWIG_opaque_memcpy(&d_result, &src_ptr);
    }
  Target &operator() () const { return *d_result; }
 private:
  Target *d_result;
};

template<class Target, class Source>
SWIGINTERN Target brute_cast(const Source& src) {
  return brute_cast_impl<Target>(src)();
}
} // end namespace swig

using swig::brute_cast;
%}

/* -------------------------------------------------------------------------
 * MEMBER FUNCTION POINTERS
 *
 * We memcpy the member function pointer to an opaque data class using
 * brute_cast.
 * ------------------------------------------------------------------------- */

// Add array wrapper to C++ code when used by Fortran fragment
%fragment("SwigOpaqueMemFunPtr", "header", noblock=1, fragment="<string.h>") {
%#if __cplusplus >= 201103L
namespace detail { class UndefinedClass; }
%#endif

struct SwigOpaqueMemFunPtr {
  char data[SWIG_MEMFUNPTR_SIZE];
%#if __cplusplus >= 201103L
  static_assert(sizeof(void (detail::UndefinedClass::*)()) <= SWIG_MEMFUNPTR_SIZE,
                "Member pointer buffer isn't large enough");
%#endif
};

SWIGINTERN SwigOpaqueMemFunPtr SwigOpaqueMemFunPtr_uninitialized() {
  SwigOpaqueMemFunPtr result;
  memset(result.data, sizeof(result.data), 0);
  return result;
}
}

// This fragment is inserted by the fortran.cxx code when an unknown class is
// encountered. Note for this to compile and not crash, the size of 'data' should
// be the same size as in SwigOpaqueMemFunPtr. 
%fragment("SwigOpaqueMemFunPtr_f", "fdecl", noblock=1, fragment="SwigOpaqueMemFunPtr")
{ type, public, bind(C) :: SwigOpaqueMemFunPtr
  integer(C_SIGNED_CHAR), dimension(SWIG_MEMFUNPTR_SIZE), public :: data
 end type}

/* -------------------------------------------------------------------------
 * TYPEMAPS
 * ------------------------------------------------------------------------- */

%typemap(ctype, fragment="SwigOpaqueMemFunPtr",
         null="SwigOpaqueMemFunPtr_uninitialized()") SWIGTYPE (CLASS::*)
  "SwigOpaqueMemFunPtr"
%typemap(imtype, in="type(SwigOpaqueMemFunPtr), intent(in), value",
         fragment="SwigOpaqueMemFunPtr_f") SWIGTYPE (CLASS::*)
  "type(SwigOpaqueMemFunPtr)"
%typemap(ftype, in="type(SwigOpaqueMemFunPtr), intent(in), value",
         fragment="SwigOpaqueMemFunPtr_f") SWIGTYPE (CLASS::*)
  "type(SwigOpaqueMemFunPtr)"

%typemap(in, noblock=1, fragment="swig::brute_cast") SWIGTYPE (CLASS::*) {
  $1 = brute_cast<$1_ltype>($input);
}
%typemap(out, noblock=1, fragment="swig::brute_cast") SWIGTYPE (CLASS::*) {
  $result = brute_cast<SwigOpaqueMemFunPtr>($1);
}
%typemap(fin) SWIGTYPE (CLASS::*)
  "$1 = $input"
%typemap(fout) SWIGTYPE (CLASS::*)
  "$result = $1"

%typemap(bindc, in="type(C_FUNPTR), value",
         fragment="SwigOpaqueMemFunPtr_f") SWIGTYPE (CLASS::*)
  "type(SwigOpaqueMemFunPtr)"

// The SWIG type system does not check the non-const memfunptr when looking for a const memfunptr. Also apply 
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::* const) };

// I'm not sure this is correct, but it allows member_funcptr_galore to pass.
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::* const &)};
