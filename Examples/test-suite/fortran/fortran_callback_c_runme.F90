! File : fortran_callback_c_c_runme.F90

#include "fassert.h"

module fortran_callback_c_mod
  use, intrinsic :: ISO_C_BINDING
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT
  integer(C_INT), save, public :: module_int
contains

function myexp(left, right) bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT), intent(in), value :: left
  integer(C_INT), intent(in), value :: right
  integer(C_INT) :: fresult

  fresult = left ** right
end function
  
function mywrite() bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT) :: fresult
  ! write(STDOUT,*) "Hi there"
  fresult = 256_c_int
end function

subroutine store_an_int(i) bind(C)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT), value, intent(in) :: i
  ! write(STDOUT,*) "Got an integer: ", i
  module_int = i
end subroutine
  
end module

program fortran_callback_c_runme
  call test_callback
contains

subroutine test_callback
  use fortran_callback_c
  use fortran_callback_c_mod
  integer(C_INT) :: i
  procedure(binary_op), pointer :: bin_op_ptr => NULL()

  ! Use callbacks with Fortran module pointers
  bin_op_ptr => myexp
  i = call_binary(c_funloc(myexp), 2, 3)
  ASSERT(i == 8)
  i = call_things(c_funloc(mywrite))
  ASSERT(i == 256)
  call also_call_things(c_funloc(store_an_int), 999)
  ASSERT(module_int == 999)

  ! Get a C function pointer to a bind(c) interface function
  i = call_binary(c_funloc(mul), 3, 7)
  ASSERT(i == 21)

  ! Get a C callback
  call c_f_procpointer(get_a_callback("mul"), bin_op_ptr)
  ASSERT(associated(bin_op_ptr))
  ASSERT(bin_op_ptr(2, 5) == 10)

  call c_f_procpointer(get_a_callback("add"), bin_op_ptr)
  ASSERT(associated(bin_op_ptr))
  ASSERT(bin_op_ptr(2, 5) == 7)

end subroutine
end program


