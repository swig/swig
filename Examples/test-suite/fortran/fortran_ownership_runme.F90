! File : fortran_ownership_runme.F90

#include "fassert.h"

program fortran_ownership_runme
  use ISO_C_BINDING
  implicit none
  integer, parameter :: swig_cmem_own_bit = 0
  integer, parameter :: swig_cmem_rvalue_bit = 1

  call test_standard
  call test_shared

contains

! Test a standard C++ object that's not marked as a shared pointer
subroutine test_standard
  use fortran_ownership
  implicit none
  type(Foo) :: a, b, c
  type(c_ptr) :: temp_cptr
  integer(c_int) :: val

  ASSERT(foo_counter == 0)
  a = Foo(1) ! Create a new object
  ASSERT(foo_counter == 1)
  b = Foo(a) ! Create a new *copy* of a
  ASSERT(foo_counter == 2)
  call b%set_val(2) ! Setting 'b' is independent of 'a'
  ASSERT(a%get_val() == 1)

  call b%release() ! Release by assigning a 'null' object
  ASSERT(foo_counter == 1)

  c = reference(a) ! Custom function: c refers to data owned by 'a'
  ASSERT(foo_counter == 1)
  ASSERT(.not. btest(c%swigdata%cmemflags, swig_cmem_own_bit))
  ASSERT(.not. btest(c%swigdata%cmemflags, swig_cmem_rvalue_bit))
  call a%set_val(3)
  ASSERT(c%get_val() == 3)

  b = const_reference(a) ! Custom function: c refers to data owned by 'a'
  ASSERT(foo_counter == 1)
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_own_bit))
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_rvalue_bit))
  call b%release()
  ASSERT(foo_counter == 1)

  c = Foo(4) ! Associate 'c' with new Foo
  ASSERT(foo_counter == 2)
  ASSERT(c%get_val() == 4) ! The reference is changed as well

  ! NOTE: returning class by intent(out) is *disabled*
  b = make_foo_subroutine(5)
  ASSERT(btest(b%swigdata%cmemflags, swig_cmem_own_bit))
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_rvalue_bit))
  ASSERT(foo_counter == 3)

  ! Return null
  call b%release()
  b = get_null()
  ASSERT(.not. c_associated(b%swigdata%cptr))

  ! Capture from function
  b = make_foo(6)
  ASSERT(btest(b%swigdata%cmemflags, swig_cmem_own_bit))
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_rvalue_bit))
  ASSERT(foo_counter == 3)

  ! Check that rvalue is automatically freed after it's used
  val = get_value(Foo(7))
  ASSERT(val == 7)
  ASSERT(foo_counter == 3)
  val = get_value_copy(Foo(8))
  ASSERT(val == 8)
  ASSERT(foo_counter == 3)

  ! Self-assignment shouldn't change ownership
  temp_cptr = b%swigdata%cptr
  b = b
  ASSERT(c_associated(b%swigdata%cptr, temp_cptr))
  ASSERT(btest(b%swigdata%cmemflags, swig_cmem_own_bit))
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_rvalue_bit))
  ASSERT(foo_counter == 3)

  call b%release()
  ASSERT(foo_counter == 2)

  call a%release() ! Free data pointed to by 'a'
  ASSERT(foo_counter == 1)

  ! Test error checking: passing a null value as a reference
  ASSERT(ierr == 0)
  c = const_reference(a)
  ASSERT(ierr == SWIG_NullReferenceError)
  ierr = 0

  call c%set_val(5)
  ! c = empty ! Release by assigning 'null'
  ! ASSERT(foo_counter == 0 + num_leaks)
  call c%release()
  ASSERT(foo_counter == 0)

end subroutine

! Test a shared pointer (e.g. TeuchosRCP<MultiVector>)
subroutine test_shared
  use fortran_ownership
  implicit none
  type(Bar) :: a, b, c

  a = Bar(1) ! Create a new object
  ASSERT(use_count(a) == 1) ! Create a new object

  b = share(a) ! Create a new *shared pointer* copy of a
  ASSERT(use_count(a) == 2)
  call b%set_val(2) ! Setting 'b' changes 'a'
  ASSERT(a%get_val() == 2)

  ! b = empty ! CAN'T Release by assigning a 'null' object
  call b%release() ! Release by assigning a 'null' object
  ASSERT(use_count(a) == 1)

  c = share(a) ! Custom function: duplicate the shared pointer
  ASSERT(use_count(a) == 2)
  call a%set_val(3)
  ASSERT(c%get_val() == 3)

  ! b = c ! CAN'T copy-construct: b is unassigned so we can't use assignment
  b = share(a)
  ASSERT(use_count(a) == 3)

  a = Bar(4) ! Create a new object and bind to 'a'
  ASSERT(use_count(a) == 1)
  ASSERT(use_count(b) == 2) ! 'b' and 'c' still point to the same data
  ASSERT(c%get_val() == 3)

  call b%release()
  b = Bar(a) ! Copy 'a', creating a new object that's bound to 'b'
  ASSERT(use_count(b) == 1)
  call a%set_val(5) ! Changing 'a' does not affect 'b'
  ASSERT(b%get_val() == 4)

  call a%release() ! Release reference to data pointed to by 'a'
  call c%set_val(5) ! This doesn't crash because pointers are shared
  ! c = empty ! CAN'T Release by assigning 'null'
  call c%release()
end subroutine

end program

