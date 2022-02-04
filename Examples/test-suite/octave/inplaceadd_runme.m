inplaceadd
a = inplaceadd.A(7);

a += 5;
if (a.val != 12)
  error("failed");
endif

a -= 5;
if a.val != 7:
  error("failed");
endif

a *= 2;

if (a.val != 14)
  error("failed");
endif

a += a;
if (a.val != 28)
  error("failed");
endif

