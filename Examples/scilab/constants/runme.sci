lines(0);
exec loader.sce;

printf("ICONST  = %i (should be 42)\n", ICONST_get());
printf("FCONST  = %f (should be 2.1828)\n", FCONST_get());
printf("CCONST  = %c (should be ''x'')\n", CCONST_get());
printf("CCONST2 = %s (this should be on a new line)\n", CCONST2_get());
printf("SCONST  = %s (should be ''Hello World'')\n", SCONST_get());
printf("SCONST2 = %s (should be "'""Hello World"""')\n", SCONST2_get());
printf("EXPR    = %f (should be 48.5484)\n", EXPR_get());
printf("iconst  = %i (should be 37)\n", iconst_get());
printf("fconst  = %f (should be 3.14)\n", fconst_get());

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

exit
