lines(0);
exec loader.sce;

a = 37
b = 42

// Now call our C function with a bunch of callbacks

printf("Trying some C callback functions\n");
printf("    a        = %i\n", a);
printf("    b        = %i\n", b);
printf("    ADD(a,b) = %i\n", do_op(a,b,funcvar_get()));

exit



