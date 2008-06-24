li_attribute

aa = li_attribute.A(1,2,3);

if (aa.a != 1)
  error
endif
aa.a = 3;
if (aa.a != 3)
  error("aa.a = %i",aa.a)
endif


if (aa.b != 2)
  error(aa.b)
endif
aa.b = 5;
if (aa.b != 5)
  error
endif



if (aa.d != aa.b)
  error
endif

if (aa.c != 3)
  error
endif

pi = li_attribute.Param_i(7);
if (pi.value != 7)
 error
endif

pi.value=3;
if (pi.value != 3)
 error
endif


b = li_attribute.B(aa);

if (b.a.c != 3)
 error
endif
  

myFoo = li_attribute.MyFoo();
myFoo.x = 8;
myClass = li_attribute.MyClass();
myClass.Foo = myFoo;
if (myClass.Foo.x != 8)
  error
endif

