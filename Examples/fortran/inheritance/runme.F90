! File : runme.f90
#define ASSERT(COND) if (.not. COND) stop 1

program test_example
  use example

  type(DerivedA), target :: derived_a
  type(DerivedB), target :: derived_b
  class(BaseClass), pointer :: base_p => null()


  ! Things that we test here:
  !  - instantiate concrete types, make sure they behave as expected
  !  - Use a pointer to a base class to point to instances of derived types, make
  !  sure that they behave as expected
  !  - Allocate a base class pointer to derived types, make sure that behaves as
  !  expected
  !  - Pass all of the above to a function that expects an object of the base
  !  class


  ! Derived A
  derived_a = DerivedA(4, 3.14)
  ASSERT(derived_a%foo() == 4*3.14)
  ASSERT(use_base(derived_a) == 4*3.14)
  call derived_a%print()

  ! Derived B
  derived_b = DerivedB(7, 5)
  ASSERT(derived_b%foo() == 7*5*2)
  ASSERT(use_base(derived_b) == 7*5*2)

  ! Associate base pointer with the above
  base_p => derived_a
  ASSERT(use_base(base_p) == 4*3.14)
  ASSERT(base_p%foo() == 4*3.14)

  base_p => derived_b
  ASSERT(use_base(base_p) == 7*5*2)
  ASSERT(base_p%foo() == 7*5*2)

  ! Allocate the base pointer directly
  base_p => NULL()
  allocate(DerivedA :: base_p)
  select type(base_p); type is(DerivedA)
    base_p = DerivedA(3, 1.26)
  end select
  ASSERT(base_p%foo() == 3*1.26)
  ASSERT(use_base(base_p) == 3*1.26)

  ! Clean up
  call derived_a%release()
  call derived_b%release()
  call base_p%release()
  deallocate(base_p)

contains

function use_base(base) result(foo)
  class(BaseClass), intent(in) :: base
  real :: foo

  foo = base%foo()
endfunction

end program

