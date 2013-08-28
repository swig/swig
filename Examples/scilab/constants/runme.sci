lines(0);
exec loader.sce;
SWIG_Init();

printf("\nConstants are wrapped by functions:\n");
printf("ICONST_get()  = %i (should be 42)\n", ICONST_get());
printf("FCONST_get()  = %5.4f (should be 2.1828)\n", FCONST_get());
printf("CCONST_get()  = ''%c'' (should be ''x'')\n", CCONST_get());
printf("CCONST2_get() = %s (this should be on a new line)\n", CCONST2_get());
printf("SCONST_get()  = ''%s'' (should be ''Hello World'')\n", SCONST_get());
printf("SCONST2_get() = ''%s'' (should be "'""Hello World"""')\n", SCONST2_get());
printf("EXPR_get()    = %5.4f (should be 48.5484)\n", EXPR_get());
printf("iconst_get()  = %i (should be 37)\n", iconst_get());
printf("fconst_get()  = %3.2f (should be 3.14)\n", fconst_get());

try
  printf("EXTERN = %s (Arg! This should not printf(anything)\n", EXTERN_get());
catch
  printf("EXTERN is not defined (good)\n");
end
try
  printf("FOO    = %i (Arg! This should not printf(anything)\n", FOO_get());
catch
  printf("FOO is not defined (good)\n");
end

printf("\nNow constants are wrapped by Scilab variables (feature scilab:const):\n");
printf("ICONST2 = %i (should be 12)\n", ICONST2);
printf("FCONST2 = %3.2f (should be 4.60)\n", FCONST2);
printf("CCONST3 = ''%c'' (should be ''a'')\n", CCONST3);
printf("CCONST4 = %s (this should be on a new line)\n", CCONST4);
printf("SCONST3 = ''%s'' (should be ''Hello World'')\n", SCONST3);
printf("SCONST4 = ''%s'' (should be "'""Hello World"""')\n", SCONST4);
printf("iconst2 = %i (should be 73)\n", iconst2);
printf("fconst2 = %3.2f (should be 6.28)\n", fconst2);

exit
