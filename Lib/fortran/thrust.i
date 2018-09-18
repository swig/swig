/* -------------------------------------------------------------------------
 * thrust.i
 *
 * Interoperability for thrust templated CUDA library. If the Fortran library
 * is using CUDA-Fortan, then include <cuda.i> before including this file; if
 * using OpenACC, then include <openacc.i> first.
 *
 * ------------------------------------------------------------------------- */
#if !defined(FORT_DEVICEPTR_TYPEMAP)
#error "Either <cuda.i> or <openacc.i> must be included before <thrust.i>"
#endif

%{
#include <thrust/device_ptr.h>
%}

/* -------------------------------------------------------------------------
 * Typemaps
 */
%define %thrust_deviceptr(T, PTRTYPE...)

  FORT_DEVICEPTR_TYPEMAP(T, %arg((PTRTYPE *DATA, size_t SIZE)))

  %typemap(in, noblock=1) (PTRTYPE *DATA, size_t SIZE) {
    $1 = $1_ltype(static_cast<T*>($input->data));
    $2 = $input->size;
  }

  %typemap(check, noblock=1) (PTRTYPE *DATA, size_t SIZE) {
    if ((thrust::raw_pointer_cast($1) == NULL) && ($2 != 0)) {
      SWIG_exception_impl("$decl", SWIG_TypeError, \
                          "Encountered null device pointer", return $null); \
    }
  }

%enddef

/* -------------------------------------------------------------------------
 * \brief CUDA compatibility datatypes
 */
namespace thrust {
template<typename T>
class device_ptr {
  public:
    typedef T value_type;

  // Create typemap for array view
  %thrust_deviceptr(T, thrust::device_ptr<T>)

};

#if 0
template<typename T>
class vector {
  /* To extract data:
   * thrust::raw_pointer_cast($self->data())
   */
};
#endif

} // end namespace thrust


%template() thrust::device_ptr<short    >;
%template() thrust::device_ptr<int      >;
%template() thrust::device_ptr<long     >;
%template() thrust::device_ptr<long long>;
%template() thrust::device_ptr<size_t   >;
%template() thrust::device_ptr<float    >;
%template() thrust::device_ptr<double   >;

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
