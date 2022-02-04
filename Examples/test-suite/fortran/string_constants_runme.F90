! File : string_constants_runme.F90

#include "fassert.h"

program string_constants_runme
  use string_constants
  use ISO_C_BINDING
  implicit none
  type(things) :: foo
  ! note: Z'deadbeef' and O'777' are used to generate hex and oct constants
  character(C_CHAR), parameter :: CR = char(int(Z'0D'), C_CHAR)
  character(C_CHAR), parameter :: LF = char(int(O'12'), C_CHAR)
  character(kind=C_CHAR, len=*), parameter :: &
    expected_aa3 = "A" // CR // "B" // LF // "C"
  character(kind=C_CHAR, len=:), allocatable :: actual_aa3
  ! integer :: i

  ASSERT(EE1 == "TUV")
  ASSERT(XX2 == "WXY")
  allocate(actual_aa3, source=get_AA3())

  ! write(*,*) (iachar(actual_aa3(i:i)), i=1,len(actual_aa3))
  ! write(*,*) (iachar(expected_aa3(i:i)), i=1,len(expected_aa3))

  ASSERT(actual_aa3 == expected_aa3)
  ASSERT(get_ZS3() == "")

  foo = things()
  ASSERT(foo%defarguments3() == "TUV")
  call foo%release()
end program

