lines(0);
ilib_verbose(0);
exec loader.sce;

// Test use of a struct (Bar)

a = new_Bar();

Bar_x_set(a, 100);
printf("a.x = %d (Sould be 100)\n", Bar_x_get(a));

delete_Bar(a);

exit
