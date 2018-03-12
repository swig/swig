/* File : director.h */
%module director

%include <std_string.i>

%{
#include <stdexcept>
#include "director.h"
%}

// Wrap the included functions both as procedures *and* as directors
%include "director.h"

%inline %{
  // Typedef for "transform" function that accepts 'this' pointer, wrapped string, and returns wrapped string
  typedef SwigArrayWrapper (*swigtd_Joiner_transform)(SwigClassWrapper const *, SwigArrayWrapper *);

  class FortranJoiner : public Joiner {
   public:
    // Fortran procedure pointer to 'transform' C wrapper
    swigtd_Joiner_transform transform_wrap_;

    virtual std::string transform(const std::string& s) const {
      if (transform_wrap_) {
        return this->transform_fortran(s);
      } else {
#if 0
        // Dispatch to base class if the method is implemented there
        return Joiner::transform(s);
#else
        throw std::runtime_error("No 'transform' method was specified");
#endif
      }
    }

   private:
    std::string transform_fortran(const std::string& str) const {
      /* construct "this" pointer */
      SwigClassWrapper self;
      self.ptr = const_cast<FortranJoiner*>(this);
      self.mem = SWIG_CREF; // since this function is const

      /* convert str -> array wrapper */
      SwigArrayWrapper arg1;
      SwigArrayWrapper fresult;
      arg1.data = (str.empty() ? NULL : const_cast<char*>(str.c_str()));
      arg1.size = str.size();

      /* pass through C fortran interface */
      fresult = (this->transform_wrap_)(&self, &arg1);

      /* convert result back to string */
      char* result = static_cast<char*>(fresult.data);
      return std::string(result, result  + fresult.size);
    }
  };
%}

#if 0
/* director WRAPPER SUPPORT */
%insert("header") %{

extern "C" {
/* Fortran BIND(C) function */
SwigArrayWrapper swigc_fp_transform(const SwigArrayWrapper* farg1);
}

// This director function wraps a single fortran function pointer.
std::string director_cb_impl(const std::string& str) {
}

extern "C" {
// swigc_director_cb: director function that can be referenced by fortran; points to director_cb_impl
SWIGEXPORT SWIGEXTERN std::string (*const swigc_director_cb)(std::string const &) = (std::string (*)(std::string const &s))(director_cb_impl);
}
%}

%insert("fpublic") %{
public :: fp_transform ! Abstract interface
public :: director_procptr ! director function that should point to user fortran code
%}

%insert("fparams") %{
! External const pointer to C++ director implementation function
type(C_FUNPTR), protected, public, bind(C, name="swigc_director_cb") :: director_cb

abstract interface
! This is the fortran native procedure interface for the equivalent C++
! function call.
  function fp_transform(s) &
    result(swig_result)
    use, intrinsic :: ISO_C_BINDING
    character(kind=C_CHAR, len=:), allocatable :: swig_result
    character(kind=C_CHAR, len=*) :: s
  end function
end interface
! User must set the following procedure
procedure(fp_transform), pointer :: director_procptr => null()
%}

%insert("fwrapper") %{
! Convert SWIG array wrapper to temporary Fortran string, pass to the fortran
! cb function, convert back to SWIG array wrapper.
! This function must have input/output arguments compatible with ISO C, and it must be marked with "bind(C)"
function swigc_fp_transform(farg1) bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  implicit none
  type(SwigArrayWrapper) :: farg1
  type(SwigArrayWrapper) :: fresult
  character(kind=C_CHAR, len=:), allocatable :: s
  character(kind=C_CHAR, len=:), allocatable :: swig_result
  character(kind=C_CHAR), dimension(:), allocatable, target, save :: fresult_chars

  ! Convert input C string array to fortran string
  call SWIG_chararray_to_string(farg1, s)
  ! Call fortran function pointer with native fortran input/output
  swig_result = director_procptr(s)
  ! Convert output back into a C-compatible form; it must not be deallocated
  ! before the C code on the other side can convert it to the native format.
  ! That's why we include the 'save' attribute on the temporary "fresult_chars".
  call SWIG_string_to_chararray(swig_result, fresult_chars, fresult)
end function
%}
#endif

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
