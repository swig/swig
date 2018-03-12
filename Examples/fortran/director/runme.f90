module my_joiners
  use director
  implicit none
  type, extends(Joiner) :: SingleJoiner
  contains
    procedure :: transform => enquote_single
  end type
  type, extends(Joiner) :: BracketJoiner
  contains
    procedure :: transform => bracket
  end type
contains
  function enquote_single(self, s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(SingleJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*), target :: s
    news = "'" // s // "'"
  end function

  function bracket(self, s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(BracketJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*), target :: s
    news = "[" // s // "]"
  end function
end module

program test_director
  implicit none

  call test_subclass()
  call test_transform()
  call test_actual()
contains

! Fortran director test
subroutine test_subclass
  use my_joiners
  use director
  implicit none
  class(Joiner), allocatable :: join

  write(*,*) "test_subclass"
  allocate(join, source=SingleJoiner())
  write(*,*) "Result: " // join%transform("whee")
  deallocate(join)

  allocate(join, source=BracketJoiner())
  write(*,*) "Result: " // join%transform("whee")

  call join%append_several()
  write(0,*) "Got string: " // join%join(", and ")
end subroutine

! Actual C++ class test
subroutine test_transform
  use director
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 
  class(Joiner), allocatable :: join

  write(*,*) "test_transform"

  allocate(join, source=QuoteJoiner())
  call join%append_several()
  str = join%join(", and ")
  write(0,*) "Got string: " // str

  deallocate(str)
  str = join_with_commas(join)
  write(0,*) "Joined with commas: " // str
end subroutine

! Actual C++ director function test
subroutine test_actual
  use my_joiners
  use director
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 
  class(Joiner), allocatable :: join

  write(*,*) "test_transform"

  allocate(join, source=SingleJoiner())
  call join%append_several()
  str = join%join(", and ")
  write(0,*) "Got string: " // str

  deallocate(str)
  str = join_with_commas(join)
  write(0,*) "Joined with commas: " // str
end subroutine

end program
! vim: set ts=2 sw=2 sts=2 tw=79 :
