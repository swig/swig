! File : templated.f90
module templated
 use, intrinsic :: ISO_C_BINDING
 implicit none
 private

 ! PUBLIC METHODS AND TYPES
 public :: Thing_Int

 enum, bind(c)
  enumerator :: SwigMemState = -1
  enumerator :: SWIG_NULL = 0
  enumerator :: SWIG_OWN
  enumerator :: SWIG_MOVE
  enumerator :: SWIG_REF
  enumerator :: SWIG_CREF
 end enum


type, bind(C) :: SwigClassWrapper
  type(C_PTR), public :: ptr = C_NULL_PTR
  integer(C_INT), public :: mem = SWIG_NULL
end type

 public :: Thing_Dbl
 public :: create_Thing_Dbl
 interface create_Thing_Dbl
  module procedure new_Thing_Dbl
 end interface
 public :: print_thing
 interface print_thing
  module procedure print_thing__SWIG_1, print_thing__SWIG_2
 end interface
 public :: create_Thing_Int
 interface create_Thing_Int
  module procedure new_Thing_Int
 end interface

 ! TYPES
 type :: Thing_Int
  ! These should be treated as PROTECTED data
  type(SwigClassWrapper), public :: swigdata
 contains
  procedure :: get => swigf_Thing_Int_get
  procedure :: release => delete_Thing_Int
  procedure, private :: swigf_assignment_Thing_Int
  generic :: assignment(=) => swigf_assignment_Thing_Int
 end type
 type :: Thing_Dbl
  ! These should be treated as PROTECTED data
  type(SwigClassWrapper), public :: swigdata
 contains
  procedure :: get => swigf_Thing_Dbl_get
  procedure :: release => delete_Thing_Dbl
  procedure, private :: swigf_assignment_Thing_Dbl
  generic :: assignment(=) => swigf_assignment_Thing_Dbl
 end type


 ! WRAPPER DECLARATIONS
 interface
function swigc_new_Thing_Int(farg1) &
bind(C, name="swigc_new_Thing_Int") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_Thing_Int_get(farg1) &
bind(C, name="swigc_Thing_Int_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
integer(C_INT) :: fresult
end function

subroutine swigc_delete_Thing_Int(farg1) &
bind(C, name="swigc_delete_Thing_Int")
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
end subroutine

  subroutine swigc_assignment_Thing_Int(self, other) &
   bind(C, name="swigc_assignment_Thing_Int")
   use, intrinsic :: ISO_C_BINDING
   import :: SwigClassWrapper
   type(SwigClassWrapper), intent(inout) :: self
   type(SwigClassWrapper), intent(in) :: other
  end subroutine
function swigc_new_Thing_Dbl(farg1) &
bind(C, name="swigc_new_Thing_Dbl") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
real(C_DOUBLE), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_Thing_Dbl_get(farg1) &
bind(C, name="swigc_Thing_Dbl_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
real(C_DOUBLE) :: fresult
end function

subroutine swigc_delete_Thing_Dbl(farg1) &
bind(C, name="swigc_delete_Thing_Dbl")
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
end subroutine

  subroutine swigc_assignment_Thing_Dbl(self, other) &
   bind(C, name="swigc_assignment_Thing_Dbl")
   use, intrinsic :: ISO_C_BINDING
   import :: SwigClassWrapper
   type(SwigClassWrapper), intent(inout) :: self
   type(SwigClassWrapper), intent(in) :: other
  end subroutine
subroutine swigc_print_thing__SWIG_1(farg1) &
bind(C, name="swigc_print_thing__SWIG_1")
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
end subroutine

subroutine swigc_print_thing__SWIG_2(farg1) &
bind(C, name="swigc_print_thing__SWIG_2")
use, intrinsic :: ISO_C_BINDING
import :: SwigClassWrapper
type(SwigClassWrapper) :: farg1
end subroutine

 end interface


contains
 ! FORTRAN PROXY CODE
function new_Thing_Int(val) &
result(self)
use, intrinsic :: ISO_C_BINDING
type(Thing_Int) :: self
integer(C_INT), intent(in) :: val
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = val
fresult = swigc_new_Thing_Int(farg1)
self%swigdata = fresult
end function

function swigf_Thing_Int_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
class(Thing_Int), intent(in) :: self
integer(C_INT) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_Thing_Int_get(farg1)
swig_result = fresult
end function

subroutine delete_Thing_Int(self)
use, intrinsic :: ISO_C_BINDING
class(Thing_Int), intent(inout) :: self
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
if (self%swigdata%mem == SWIG_OWN) then
call swigc_delete_Thing_Int(farg1)
end if
self%swigdata%ptr = C_NULL_PTR
self%swigdata%mem = SWIG_NULL
end subroutine

  subroutine swigf_assignment_Thing_Int(self, other)
   use, intrinsic :: ISO_C_BINDING
   class(Thing_Int), intent(inout) :: self
   type(Thing_Int), intent(in) :: other
   call swigc_assignment_Thing_Int(self%swigdata, other%swigdata)
  end subroutine
function new_Thing_Dbl(val) &
result(self)
use, intrinsic :: ISO_C_BINDING
type(Thing_Dbl) :: self
real(C_DOUBLE), intent(in) :: val
type(SwigClassWrapper) :: fresult 
real(C_DOUBLE) :: farg1 

farg1 = val
fresult = swigc_new_Thing_Dbl(farg1)
self%swigdata = fresult
end function

function swigf_Thing_Dbl_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
real(C_DOUBLE) :: swig_result
class(Thing_Dbl), intent(in) :: self
real(C_DOUBLE) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_Thing_Dbl_get(farg1)
swig_result = fresult
end function

subroutine delete_Thing_Dbl(self)
use, intrinsic :: ISO_C_BINDING
class(Thing_Dbl), intent(inout) :: self
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
if (self%swigdata%mem == SWIG_OWN) then
call swigc_delete_Thing_Dbl(farg1)
end if
self%swigdata%ptr = C_NULL_PTR
self%swigdata%mem = SWIG_NULL
end subroutine

  subroutine swigf_assignment_Thing_Dbl(self, other)
   use, intrinsic :: ISO_C_BINDING
   class(Thing_Dbl), intent(inout) :: self
   type(Thing_Dbl), intent(in) :: other
   call swigc_assignment_Thing_Dbl(self%swigdata, other%swigdata)
  end subroutine
subroutine print_thing__SWIG_1(t)
use, intrinsic :: ISO_C_BINDING
class(Thing_Int), intent(in) :: t
type(SwigClassWrapper) :: farg1 

farg1 = t%swigdata
call swigc_print_thing__SWIG_1(farg1)
end subroutine

subroutine print_thing__SWIG_2(t)
use, intrinsic :: ISO_C_BINDING
class(Thing_Dbl), intent(in) :: t
type(SwigClassWrapper) :: farg1 

farg1 = t%swigdata
call swigc_print_thing__SWIG_2(farg1)
end subroutine


end module
! vim: set ts=2 sw=2 sts=2 tw=129 :
