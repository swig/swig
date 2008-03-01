refcount
#
# very innocent example
#

a = A3();
b1 = B(a);
b2 = B.create(a);


if (a.ref_count() != 3)
  error("This program will crash... now")
endif


rca = b2.get_rca();
b3 = B.create(rca);

if (a.ref_count() != 5)
  error("This program will crash... now")
endif


v = vector_A(2);
v(0) = a;
v(1) = a;

x = v(0);
clear v;





