/* File : director.h */
%module director

%include <std_string.i>

%{
#include <stdexcept>
#include "director.h"
%}

%rename(JoinerBase) join::Joiner;

// Wrap the included functions both as procedures *and* as directors
%include "director.h"

%insert("header") %{
extern "C" {
/* Fortran BIND(C) function */
SwigArrayWrapper swigd_Joiner_transform(void* farg1, const SwigArrayWrapper* farg2);
SwigArrayWrapper swigd_Joiner_join_default(void* farg1);
}
%}

%fortranprepend Joiner::~Joiner() %{
  type(C_PTR) :: fself_ptr
  type(JoinerHandle), pointer :: handle
  fself_ptr = swigc_Joiner_fhandle(self%swigdata)
  call c_f_pointer(cptr=fself_ptr, fptr=handle)
%}

%fortranappend Joiner::~Joiner() %{
  ! Release the allocated handle
  deallocate(handle)
%}

%insert("header") %{
#include <bitset>
%}

%inline %{
  class Joiner : public join::Joiner {
    using Base = join::Joiner;
    // Pointer to polymorphic fortran pointer
    void* fhandle_;
    // Which functions are overridden
    std::bitset<1> overridden_;
   public:
    Joiner() : fhandle_(NULL) { /* * */ }

    virtual std::string transform(const std::string& str) const {
      /* construct "this" pointer */
      SwigClassWrapper self;
      self.ptr = const_cast<Joiner*>(this);
      self.mem = SWIG_CREF; // since this function is const

      /* convert str -> array wrapper */
      SwigArrayWrapper arg1;
      SwigArrayWrapper fresult;
      arg1.data = (str.empty() ? NULL : const_cast<char*>(str.c_str()));
      arg1.size = str.size();

      /* pass through C fortran interface */
      fresult = swigd_Joiner_transform(&self, &arg1);

      /* convert result back to string */
      char* result = static_cast<char*>(fresult.data);
      return std::string(result, result  + fresult.size);
    }

    virtual std::string join_default() const {
      if (!overridden_[0]) return Base::join_default();
      /* construct "this" pointer */
      SwigClassWrapper self;
      self.ptr = const_cast<Joiner*>(this);
      self.mem = SWIG_CREF; // since this function is const

      /* convert str -> array wrapper */
      SwigArrayWrapper fresult;
      /* pass through C fortran interface */
      fresult = swigd_Joiner_join_default(&self);

      /* convert result back to string */
      char* result = static_cast<char*>(fresult.data);
      return std::string(result, result  + fresult.size);
    }

    const void* fhandle() const { return this->fhandle_; }

    void init(void* fh) { fhandle_ = fh; }
    void swig_override(int idx) { overridden_[idx] = true; }
  };
%}

%insert("ftypes") %{
  type :: JoinerHandle
    class(Joiner), pointer :: data
  end type
%}

%insert("fpublic") %{
public :: init_Joiner
%}

%insert("fwrapper") %{
! Convert a ISO-C class pointer struct into a user Fortran native pointer
subroutine c_f_pointer_Joiner(clswrap, fptr)
  type(SwigClassWrapper), intent(in) :: clswrap
  class(Joiner), pointer, intent(out) :: fptr
  type(JoinerHandle), pointer :: handle
  type(C_PTR) :: fself_ptr
  ! Convert C handle to fortran pointer
  fself_ptr = swigc_Joiner_fhandle(clswrap)
  ! *** NOTE *** : gfortran 5 through 7 falsely claim the next line is not standards compliant. Since 'handle' is a scalar and
  ! not an array it should be OK, but TS29113 explicitly removes the interoperability requirement for fptr.
  ! Error: TS 29113/TS 18508: Noninteroperable array FPTR at (1) to C_F_POINTER: Expression is a noninteroperable derived type
  ! see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=84924
  call c_f_pointer(cptr=fself_ptr, fptr=handle)
  ! Access the pointer inside that
  fptr => handle%data
end subroutine

! Convert SWIG array wrapper to temporary Fortran string, pass to the fortran
! cb function, convert back to SWIG array wrapper.
! This function must have input/output arguments compatible with ISO C, and it must be marked with "bind(C)"
function swigd_Joiner_transform(farg1, farg2) &
    bind(C, name="swigd_Joiner_transform") &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  implicit none
  type(SwigClassWrapper), intent(in) :: farg1
  type(SwigArrayWrapper), intent(in) :: farg2
  type(SwigArrayWrapper) :: fresult
  class(Joiner), pointer :: self
  character(kind=C_CHAR, len=:), allocatable :: s
  character(kind=C_CHAR, len=:), allocatable :: swig_result
  character(kind=C_CHAR), dimension(:), allocatable, save :: fresult_chars

  ! Get pointer to Fortran object from class wrapper
  call c_f_pointer_Joiner(farg1, self)
  ! Convert input C string array to fortran string
  call SWIG_chararray_to_string(farg2, s)
  ! Call fortran function pointer with native fortran input/output
  swig_result = self%transform(s)
  ! Convert output back into a C-compatible form; it must not be deallocated
  ! before the C code on the other side can convert it to the native format.
  ! That's why we include the 'save' attribute on the temporary "fresult_chars".
  ! (Alternatively, we could add a fortran binding for a call to deallocate)
  call SWIG_string_to_chararray(swig_result, fresult_chars, fresult)
end function

function swigd_Joiner_join_default(farg1) &
    bind(C, name="swigd_Joiner_join_default") &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  implicit none
  type(SwigClassWrapper), intent(in) :: farg1
  type(SwigArrayWrapper) :: fresult
  class(Joiner), pointer :: self
  character(kind=C_CHAR, len=:), allocatable :: swig_result
  character(kind=C_CHAR), dimension(:), allocatable, save :: fresult_chars

  ! Get pointer to Fortran object from class wrapper
  call c_f_pointer_Joiner(farg1, self)

  swig_result = self%join_default()
  call SWIG_string_to_chararray(swig_result, fresult_chars, fresult)
end function

subroutine init_Joiner(self)
  class(Joiner), target :: self
  type(JoinerHandle), pointer :: handle
  allocate(handle)
  handle%data => self
  self%swigdata = swigc_new_Joiner()
  call swigc_Joiner_init(self%swigdata, c_loc(handle))
end subroutine
%}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
