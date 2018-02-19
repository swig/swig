! File : test-copy-elision.f90
module test_foo
  enum, bind(c)
    enumerator :: Ownership = -1
    enumerator :: REFERENCES = 0
    enumerator :: OWNS = 1
    enumerator :: MOVING = 2
  end enum
  type :: Foo
    integer :: val = 0
    integer(kind(Ownership)) :: flag = REFERENCES
  contains
    procedure, private :: assign_Foo
    generic :: assignment(=) => assign_Foo
  end type

contains
  subroutine assign_Foo(self, other)
    class(Foo), intent(inout) :: self
    type(Foo), intent(in) :: other
    self%val = other%val
    self%flag = other%flag
    if (self%flag == MOVING) then
      self%flag = OWNS
    else
      ! Increment value as a "copy"
      self%val = self%val + 1
    end if
  end subroutine

  function emit_foo(val) result(res)
    integer, intent(in) :: val
    type(Foo) :: res
    res%val = val
    res%flag = MOVING
  end function

  subroutine replace_foo(res, val)
    type(Foo), intent(inout) :: res
    integer, intent(in) :: val
    res%val = val
    res%flag = OWNS
  end subroutine

  subroutine print_foo(varname, f)
    character(len=*), target :: varname
    type(Foo), intent(in) :: f
    write(0,*) varname, ":", f%val, f%flag
  end subroutine

end module

program main
  call test_semantics()
contains
  subroutine test_semantics()
    use :: test_foo
    type(Foo) :: f1, f3
    type(Foo), target :: f2
    type(Foo), pointer :: fptr

    f1 = emit_foo(1)
    call print_foo("f1 is 1   ", f1)
    call replace_foo(f2, 3)
    call print_foo("f2    ", f2)
    f3 = f2
    call print_foo("f3 is f2+1", f3)
    call print_foo("emitting  ", emit_foo(5))
    fptr => f2
    call print_foo("f2 ptr  ", fptr)


  end subroutine
end program

!-----------------------------------------------------------------------------!
! end of spdemo/test-copy-elision.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
