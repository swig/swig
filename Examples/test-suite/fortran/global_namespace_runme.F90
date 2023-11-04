! File : global_namespace_runme.F90

#include "fassert.h"

program global_namespace_runme
  use global_namespace
  use ISO_C_BINDING
  implicit none
  type(Klass1) :: k1
  type(Klass2) :: k2
  type(Klass3) :: k3
  type(Klass4) :: k4
  type(Klass5) :: k5
  type(Klass6) :: k6
  type(Klass7) :: k7_wrapped
  type(SWIGTYPE_p_p_Klass7) :: k7
  type(KlassMethods) :: km
  type(XYZ1) :: x1
  type(XYZ2) :: x2
  type(XYZ3) :: x3
  type(XYZ4) :: x4
  type(XYZ5) :: x5
  type(XYZ6) :: x6
  type(SWIGTYPE_p_p_Space__XYZ7) :: x7
  type(XYZMethods) :: xyzm
  type(TheEnumMethods) :: tem

  k1 = Klass1()
  k2 = Klass2()
  k3 = Klass3()
  k4 = Klass4()
  k5 = Klass5()
  k6 = Klass6()

  call km%methodA(k1, k2, k3, k4, k5, k6, k7)
  call km%methodB(k1, k2, k3, k4, k5, k6, k7)

  call k1%release()
  call k2%release()
  call k3%release()
  call k4%release()
  call k5%release()
  call k6%release()

  k1 = getKlass1A()
  k2 = getKlass2A()
  k3 = getKlass3A()
  k4 = getKlass4A()
  k5 = getKlass5A()
  k6 = getKlass6A()
  k7_wrapped = getKlass7A()

  call k1%release()
  call k2%release()
  call k3%release()
  call k4%release()
  call k5%release()
  call k6%release()

  k1 = getKlass1B()
  k2 = getKlass2B()
  k3 = getKlass3B()
  k4 = getKlass4B()
  k5 = getKlass5B()
  k6 = getKlass6B()

  call km%methodA(k1, k2, k3, k4, k5, k6, k7)
  call km%methodB(k1, k2, k3, k4, k5, k6, k7)

  call k1%release()
  call k2%release()
  call k3%release()
  call k4%release()
  call k5%release()
  call k6%release()

  x1 = XYZ1()
  x2 = XYZ2()
  x3 = XYZ3()
  x4 = XYZ4()
  x5 = XYZ5()
  x6 = XYZ6()

  call xyzm%methodA(x1, x2, x3, x4, x5, x6, x7)
  call xyzm%methodB(x1, x2, x3, x4, x5, x6, x7)

  call x1%release()
  call x2%release()
  call x3%release()
  call x4%release()
  call x5%release()
  call x6%release()

  call tem%methodA(theenum1, theenum2, theenum3)
  call tem%methodA(theenum1, theenum2, theenum3)
    
end program


