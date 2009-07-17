// builder the *.so
exec builder.sce

//loader the *.so
exec loader.sce

//Now try the typemap library
//This should be much easier. Now how it is no longer
//necessary to manufacture pointers.

printf("Trying the typemap library\n");
r = sub(37,42);
printf("     37 - 42 = %i\n",r);

//Now try the version with multiple return values

printf("Testing multiple return values\n");
[q,r] = divide(42,37);
printf("     42/37 = %d remainder %d\n",q,r);

exit

