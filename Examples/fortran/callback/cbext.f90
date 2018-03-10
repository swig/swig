module cbext
 use, intrinsic :: ISO_C_BINDING
 implicit none
 public
  
! <<<<<< SWIG COPY
type, bind(C) :: SwigArrayWrapper
  type(C_PTR), public :: data = C_NULL_PTR
  integer(C_SIZE_T), public :: size = 0
end type
! >>>>>>

! External pointer that must be set to our Fortran ISO C layer callback
type(C_FUNPTR), public, bind(C, name="swigc_fortran_cb") :: fortran_cb

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
! This signature is for the ISO C adapter layer. It's not needed to get the
! callback stuff working.
!   function swigc_fp_transform(farg1) &
!     result(fresult)
!     use, intrinsic :: ISO_C_BINDING
!     import :: SwigArrayWrapper
!     type(SwigArrayWrapper) :: farg1
!     type(SwigArrayWrapper) :: fresult
!   end function
end interface

procedure(fp_transform), pointer :: fortran_procptr => null()
! procedure(swigc_fp_transform), pointer :: swigc_procptr => null()

interface
subroutine printcrap() bind(C, name="printcrap")
end subroutine
end interface
  
contains
! <<<<<< SWIG COPY
subroutine SWIG_string_to_chararray(string, chars, wrap)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR, len=*), intent(IN) :: string
  character(kind=C_CHAR), dimension(:), target, allocatable, intent(OUT) :: chars
  type(SwigArrayWrapper), intent(OUT) :: wrap
  integer :: i

  allocate(character(kind=C_CHAR) :: chars(len(string) + 1))
  do i=1,len(string)
    chars(i) = string(i:i)
  end do
  i = len(string) + 1
  chars(i) = C_NULL_CHAR
  wrap%data = c_loc(chars)
  wrap%size = len(string)
end subroutine


subroutine SWIG_chararray_to_string(wrap, string)
  use, intrinsic :: ISO_C_BINDING
  type(SwigArrayWrapper), intent(IN) :: wrap
  character(kind=C_CHAR, len=:), allocatable, intent(OUT) :: string
  character(kind=C_CHAR), dimension(:), pointer :: chars
  integer(kind=C_SIZE_T) :: i
  call c_f_pointer(wrap%data, chars, [wrap%size])
  allocate(character(kind=C_CHAR, len=wrap%size) :: string)
  do i=1, wrap%size
    string(i:i) = chars(i)
  enddo
end subroutine
! >>>>>>

  function enquote_single(s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*) :: s
    news = "'" // s // "'"
  end function

  function bracket(s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*) :: s
    news = "[" // s // "]"
  end function

  ! Convert SWIG array wrapper to temporary Fortran string, pass to the fortran
  ! cb function, convert back to SWIG array wrapper.
  ! This function must have input/output arguments compatible with ISO C.
  function swigc_fp_transform(farg1) bind(C) &
      result(fresult)
    use, intrinsic :: ISO_C_BINDING
    implicit none
    type(SwigArrayWrapper) :: farg1
    type(SwigArrayWrapper) :: fresult
    character(kind=C_CHAR, len=:), allocatable :: s
    character(kind=C_CHAR, len=:), allocatable :: swig_result
    character(kind=C_CHAR), dimension(:), allocatable, target, save :: fresult_chars

    ! Convert input array to f string
    call SWIG_chararray_to_string(farg1, s)
    ! Call pure fortran function
    swig_result = fortran_procptr(s)
    ! Convert output back into a C-compatible form; it must not be deallocated
    ! before the C code on the other side can convert it to the native format.
    ! That's why we include the 'save' attribute on the output.
    call SWIG_string_to_chararray(swig_result, fresult_chars, fresult)
  end function
      
end module


