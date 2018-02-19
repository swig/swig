! File : simplest.f90
module simplest
 use, intrinsic :: ISO_C_BINDING
 implicit none
 private

 ! PUBLIC METHODS AND TYPES
 public :: add

 ! WRAPPER DECLARATIONS
 interface
function add(a, b) &
bind(C, name="add") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
integer(C_INT), value :: a
integer(C_INT), value :: b
integer(C_INT) :: fresult
end function

 end interface


end module
! vim: set ts=2 sw=2 sts=2 tw=129 :
