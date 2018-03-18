module my_joiners
  use director
  use, intrinsic :: ISO_C_BINDING
  implicit none
  type, extends(FortranJoiner) :: SingleJoiner
  contains
    procedure :: transform => transform_enquote_single
  end type
  type, extends(FortranJoiner) :: BracketJoiner
  contains
    procedure :: transform => transform_bracket
    procedure :: join_default => join_default_bracket
  end type
  type, extends(FortranJoiner) :: ArbitraryJoiner
    character(kind=C_CHAR, len=1) :: ch = '"'
  contains
    procedure :: transform => arb_transform
  end type
contains
  function transform_enquote_single(self, str) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(SingleJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*), target :: str
    news = "'" // str // "'"
  end function

  function transform_bracket(self, str) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(BracketJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*), target :: str
    news = "[" // str // "]"
  end function

  function join_default_bracket(self) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(BracketJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    news = self%join("><")
  end function

  function arb_transform(self, str) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    class(ArbitraryJoiner), intent(in) :: self
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*), target :: str
    news = self%ch // str // self%ch
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
  class(FortranJoiner), allocatable :: join

  ! NOTE: because we're not calling any C functions here, we don't actually
  ! have to call init_FortranJoiner

  write(*,*) "test_subclass"
  allocate(join, source=SingleJoiner())
  write(*,*) "Transformed: " // join%transform("whee")
  deallocate(join)

  allocate(join, source=BracketJoiner())
  write(*,*) "Transformed: " // join%transform("whee")
  deallocate(join)

!  call join%append_several()
!  write(0,*) "Transformed: " // join%join(", and ")
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
  write(0,*) "Transformed: " // str

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
  class(FortranJoiner), allocatable :: join

  write(*,*) "test_actual"

  ! -- SingleJoiner --

  allocate(join, source=SingleJoiner())
  call init_FortranJoiner(join)
  call join%append_several()
  str = join%join(", and ")
  write(0,*) "Transformed: " // str

  deallocate(str)
  str = join_with_commas(join)
  write(0,*) "Joined with commas: " // str
  deallocate(str)
  str = join_default(join)
  write(0,*) "Joined with default: " // str

  call join%release()
  deallocate(join)

  ! -- BracketJoiner --

  allocate(join, source=BracketJoiner())
  call init_FortranJoiner(join)
  call join%swig_override(0)
  call join%append_several()

  deallocate(str)
  str = join_with_commas(join)
  write(0,*) "Joined with commas: " // str
  deallocate(str)
  str = join_default(join)
  write(0,*) "Joined with default: " // str

  call join%release()
  deallocate(join)
  
  ! -- ArbitraryJoiner --

  allocate(join, source=ArbitraryJoiner())
  call init_FortranJoiner(join)
  call join%append_several()
  str = join%join(", and ")
  write(0,*) "Transformed: " // str
  deallocate(str)

  select type (j => join)
  class is (ArbitraryJoiner)
    j%ch = '!'
  end select
  str = join%join(", and ")
  write(0,*) "Transformed: " // str
  deallocate(str)

  str = join_with_commas(join)
  write(0,*) "Joined with commas: " // str

  call join%release()
  deallocate(join)
end subroutine

end program
! vim: set ts=2 sw=2 sts=2 tw=79 :
