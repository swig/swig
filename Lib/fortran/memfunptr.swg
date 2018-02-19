/* -------------------------------------------------------------------------
 * memfunptr.swg
 * ------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------
 * BRUTE CAST
 * ------------------------------------------------------------------------- */

// This fragment allows making an opaque datatype from C++ member function
// pointers (which according to the standard CANNOT be converted to a pointer).
// encountered. Its syntax is exactly like static_cast.
// Note that the <string.h> fragment imports size_t into the global namespace.
%fragment("swig::brute_cast", "runtime", fragment="<string.h>") %{
template<typename Dst, typename Src>
SWIGINTERN void SWIG_opaque_memcpy(Dst* dst, const Src* src) {
  const size_t MINSIZE
    = (sizeof(dst) < sizeof(src) ? sizeof(dst) : sizeof(src));
  const size_t MAXSIZE
    = (sizeof(dst) > sizeof(src) ? sizeof(dst) : sizeof(src));
  std::memcpy(dst, src, MINSIZE);
  if (MAXSIZE > MINSIZE)
  {
    std::memset(static_cast<char*>(static_cast<void*>(dst)) + MINSIZE,
                MAXSIZE - MINSIZE,
                0);
  }
}

namespace swig {
template<typename Target>
class brute_cast_impl {
 public:
  template<typename Source>
    brute_cast_impl(const Source& src_fwd) {
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
      Source* src_ptr = &src_ref;
      SWIG_opaque_memcpy(&d_result, &src_ptr);
    }
  Target& operator() () const { return *d_result; }
 private:
  Target* d_result;
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
%fragment("SwigOpaqueMemFunPtr", "header", fragment="<string.h>") %{
struct SwigOpaqueMemFunPtr {
  enum { MEMPTR_SIZE = 32 };
  char data[MEMPTR_SIZE];
#if __cplusplus >= 201103L
  static_assert(sizeof(void (detail::UndefinedClass::*)()) <= MEMPTR_SIZE,
                "Member pointer buffer isn't large enough");
#endif
};

SWIGINTERN SwigOpaqueMemFunPtr SwigOpaqueMemFunPtr_uninitialized() {
  SwigOpaqueMemFunPtr result;
  std::memset(result.data, sizeof(result.data), 0);
  return result;
}
%}

// This fragment is inserted by the fortran.cxx code when an unknown class is
// encountered. Note for this to compile and not crash, the size of 'data' should
// be the same size as in SwigOpaqueMemFunPtr. This can be accomplished more
// elegantly by  generating a config.h file and including it in Fortran using
// the C preprocessor.
%fragment("SwigOpaqueMemFunPtr_f", "fpublic", noblock=1, fragment="SwigOpaqueMemFunPtr") %{
type, public, bind(C) :: SwigOpaqueMemFunPtr
  integer(C_SIGNED_CHAR), dimension(32), public :: data
end type
%}

/* -------------------------------------------------------------------------
 * TYPEMAPS
 * ------------------------------------------------------------------------- */

%typemap(ctype, fragment="SwigOpaqueMemFunPtr",
         null="SwigOpaqueMemFunPtr_uninitialized()") SWIGTYPE (CLASS::*) %{
  SwigOpaqueMemFunPtr
%}
%typemap(in, fragment="swig::brute_cast") SWIGTYPE (CLASS::*) %{
  $1 = brute_cast<$1_ltype>($input);
%}
%typemap(out, fragment="swig::brute_cast") SWIGTYPE (CLASS::*) %{
  $result = brute_cast<SwigOpaqueMemFunPtr>($1);
%}
%typemap(imtype, in="type(SwigOpaqueMemFunPtr), intent(in), value",
         import="SwigOpaqueMemFunPtr",
         fragment="SwigOpaqueMemFunPtr_f") SWIGTYPE (CLASS::*)
  "type(SwigOpaqueMemFunPtr)"
%typemap(ftype, out="type(SwigOpaqueMemFunPtr)",
         fragment="SwigOpaqueMemFunPtr_f") SWIGTYPE (CLASS::*)
  "type(SwigOpaqueMemFunPtr), intent(in), value"
%typemap(fin) SWIGTYPE (CLASS::*)
  "$1 = $input"
%typemap(fout) SWIGTYPE (CLASS::*)
  "$result = $1"

// Copy to immutable member function pointers
FORT_COPY_TYPEMAPS(SWIGTYPE (CLASS::*),
                   SWIGTYPE (CLASS::* const));
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
