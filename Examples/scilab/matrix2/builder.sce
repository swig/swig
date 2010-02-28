ilib_name = "matrixliblib";
files = ["matrixlib_wrap.c","matrixlib.o"];
libs = [];
table = ["sumitems","_wrap_sumitems";"getValues","_wrap_getValues";];
ilib_build(ilib_name,table,files,libs);
exit