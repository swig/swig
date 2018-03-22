! File : unions_runme.f90

program unions_runme
  use unions
  use ISO_C_BINDING
  implicit none
  type(SmallStruct) :: small, uni_small, big_smallstruct
  type(BigStruct) :: big, uni_big
  type(EmbeddedUnionTest) :: eut
  type(EmbeddedUnionTest_uni) :: uni
  integer(C_INT) :: Jack1, Num1, Num2
  integer(C_SHORT) :: Jill1, Jill2

  ! Create new instances of SmallStruct and BigStruct for later use
  small = SmallStruct()
  call small%set_jill(200_C_SHORT)

  big = BigStruct()
  call big%set_smallstruct(small)
  call big%set_jack(300_C_INT)

  ! Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
  ! Ensure values in EmbeddedUnionTest are set correctly for each.
  eut = EmbeddedUnionTest()
  uni = eut%get_uni()

  ! First check the SmallStruct in EmbeddedUnionTest
  call eut%set_number(1_C_INT)
  call uni%set_small(small)

  uni_small = uni%get_small()
  Jill1 = uni_small%get_jill()
  if (Jill1 /= 200_C_SHORT) then
    write(0,*) "Runtime test1 failed. eut%uni%small%jill=", Jill1
    stop 1
  end if

  Num1 = eut%get_number()
  if (Num1 /= 1_C_INT) then
    write(0,*) "Runtime test2 failed. eut%number=", Num1
    stop 1
  end if

  ! Secondly check the BigStruct in EmbeddedUnionTest
  call eut%set_number(2_C_INT)
  call uni%set_big(big)

  uni_big = uni%get_big()
  Jack1 = uni_big%get_jack()
  if (Jack1 /= 300_C_INT) then
    write(0,*) "Runtime test3 failed. eut%uni%big%jack=", Jack1
    stop 1
  end if

  big_smallstruct = uni_big%get_smallstruct()
  Jill2 = big_smallstruct%get_jill()
  if (Jill2 /= 200_C_SHORT) then
    write(0,*) "Runtime test4 failed. eut%uni%big%smallstruct%jill=", Jill2
    stop 1
  end if

  Num2 = eut%get_number()
  if (Num2 /= 2_C_INT) then
    write(0,*) "Runtime test5 failed. eut%number=", Num2
    stop 1
  end if

  print*, "SUCCESS!"

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
