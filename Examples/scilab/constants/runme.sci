lines(0);
ilib_verbose(0);
exec loader.sce;
example_Init();

printf("\nConstants are wrapped by functions:\n");
printf("ICONST  = %i (should be 42)\n", ICONST);
printf("FCONST  = %5.4f (should be 2.1828)\n", FCONST);
printf("SCONST  = ''%s'' (should be ''Hello World'')\n", SCONST);
printf("EXPR    = %5.4f (should be 48.5484)\n", EXPR);
printf("iconst  = %i (should be 37)\n", iconst);
printf("fconst  = %3.2f (should be 42.20)\n", fconst);

exit
