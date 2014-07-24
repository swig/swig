lines(0);
ilib_verbose(0);
exec loader.sce;
example_Init();

printf("\nConstants are wrapped by functions:\n");
printf("ICONST_get()  = %i (should be 42)\n", ICONST_get());
printf("FCONST_get()  = %5.4f (should be 2.1828)\n", FCONST_get());
printf("SCONST_get()  = ''%s'' (should be ''Hello World'')\n", SCONST_get());
printf("EXPR_get()    = %5.4f (should be 48.5484)\n", EXPR_get());
printf("iconst_get()  = %i (should be 37)\n", iconst_get());
printf("fconst_get()  = %3.2f (should be 42.20)\n", fconst_get());

exit
