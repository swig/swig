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


