! File : char_binary_runme.F90

#include "fassert.h"

program char_binary_runme
  use char_binary
  use ISO_C_BINDING
  implicit none
  character(len=*), parameter :: withnull = "hil" // C_NULL_CHAR
  type(Test) :: t
  type(SWIGTYPE_p_char) :: pc

  if (len(withnull) /= 4) stop 2

  t = Test()
  ASSERT(t%strlen("hile") == 4)
  ASSERT(t%ustrlen("hile") == 4)

  ASSERT(t%strlen(withnull) == 4)
  ASSERT(t%ustrlen(withnull) == 4)

  pc = New_pchar(5)
  call Pchar_setitem(pc, 0, 'h')
  call Pchar_setitem(pc, 1, 'o')
  call Pchar_setitem(pc, 2, 'l')
  call Pchar_setitem(pc, 3, 'a')
  call Pchar_setitem(pc, 4, C_NULL_CHAR)
  call Delete_pchar(pc)
end program


