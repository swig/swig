// builder the *.so
exec example_builder.sce

//loader the *.so
exec loader.sce

//create a struct
a=new_Bar();
Bar_x_set(a,100);
Bar_x_get(a)

exit


