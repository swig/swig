/* File : director.h */
%module director

%include <std_string.i>

%{
#include <stdexcept>
#include "director.h"
%}

// Wrap the included functions both as procedures *and* as directors
%include "director.h"

%insert("header") %{
extern "C" {
/* Fortran BIND(C) function */
SwigArrayWrapper swigc_transform(void* farg1, const SwigArrayWrapper* farg2);
}
%}

%fortranprepend FortranJoiner::transform %{
  ! Prepended stuff here
%}

%fortranprepend FortranJoiner::~FortranJoiner() %{
  type(C_PTR) :: fself_ptr
  type(FortranJoinerWrapper), pointer :: handle
  fself_ptr = swigc_FortranJoiner_fhandle(self%swigdata)
  call c_f_pointer(cptr=fself_ptr, fptr=handle)
%}

%fortranappend FortranJoiner::~FortranJoiner() %{
  ! Release the allocated handle
  deallocate(handle)
%}


%inline %{
  class FortranJoiner : public Joiner {
    // Pointer to polymorphic fortran pointer
    void* fhandle_;
   public:
    FortranJoiner() : fhandle_(NULL) { /* * */ }

    virtual std::string transform(const std::string& str) const {
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
      fresult = swigc_transform(&self, &arg1);

      /* convert result back to string */
      char* result = static_cast<char*>(fresult.data);
      return std::string(result, result  + fresult.size);
    }

    const void* fhandle() const { return this->fhandle_; }

    void init(void* fh) { fhandle_ = fh; }
  };
%}

%insert("ftypes") %{
  type :: FortranJoinerWrapper
    class(FortranJoiner), pointer :: data
  end type
%}

%insert("fpublic") %{
public :: init_FortranJoiner
%}

%insert("fwrapper") %{
! Convert SWIG array wrapper to temporary Fortran string, pass to the fortran
! cb function, convert back to SWIG array wrapper.
! This function must have input/output arguments compatible with ISO C, and it must be marked with "bind(C)"
function swigc_transform(farg1, farg2) bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  implicit none
  type(SwigClassWrapper) :: farg1
  type(SwigArrayWrapper) :: farg2
  type(SwigArrayWrapper) :: fresult
  type(C_PTR) :: fself_ptr
  type(FortranJoinerWrapper), pointer :: handle
  class(FortranJoiner), pointer :: self
  character(kind=C_CHAR, len=:), allocatable :: s
  character(kind=C_CHAR, len=:), allocatable :: swig_result
  character(kind=C_CHAR), dimension(:), allocatable, target, save :: fresult_chars

  ! Convert C handle to fortran pointer
  fself_ptr = swigc_FortranJoiner_fhandle(farg1)
  ! *** NOTE *** : gfortran 5 through 7 falsely claim the next line is not standards compliant. Since 'handle' is a scalar and
  ! not an array it should be OK, but TS29113 explicitly removes the interoperability requirement for fptr.
  ! Error: TS 29113/TS 18508: Noninteroperable array FPTR at (1) to C_F_POINTER: Expression is a noninteroperable derived type
  ! see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=84924
  call c_f_pointer(cptr=fself_ptr, fptr=handle)
  ! Access the pointer inside that
  self => handle%data

  ! Convert input C string array to fortran string
  call SWIG_chararray_to_string(farg2, s)
  ! Call fortran function pointer with native fortran input/output
  swig_result = self%transform(s)
  ! Convert output back into a C-compatible form; it must not be deallocated
  ! before the C code on the other side can convert it to the native format.
  ! That's why we include the 'save' attribute on the temporary "fresult_chars".
  call SWIG_string_to_chararray(swig_result, fresult_chars, fresult)
end function

subroutine init_FortranJoiner(self)
  class(FortranJoiner), target :: self
  type(FortranJoinerWrapper), pointer :: handle
  allocate(handle)
  handle%data => self
  self%swigdata = swigc_new_FortranJoiner()
  call swigc_FortranJoiner_init(self%swigdata, c_loc(handle))
end subroutine
%}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
