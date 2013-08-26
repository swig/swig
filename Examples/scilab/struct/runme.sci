lines(0);
exec loader.sce;

//create a struct
a=new_Bar();
Bar_x_set(a,100);
printf("a.x = %d (Sould be 100)\n", Bar_x_get(a));

exit


