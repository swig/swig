exec example.sce;

printf("ICONST  = %i (should be 42)\n", example.ICONST);
printf("FCONST  = %f (should be 2.1828)\n",example. FCONST);
printf("CCONST  = %c (should be ''x'')\n", example.CCONST);
printf("CCONST2 = %s (this should be on a new line)\n", example.CCONST2);
printf("SCONST  = %s (should be ''Hello World'')\n", example.SCONST);
printf("SCONST2 = %s (should be "'""Hello World"""')\n", example.SCONST2);
printf("EXPR    = %f (should be 48.5484)\n",example.EXPR);
printf("iconst  = %i (should be 37)\n", example.iconst);
printf("fconst  = %f (should be 3.14)\n", example.fconst);

try
  printf("EXTERN = %s (Arg! This should not printf(anything)\n", example.EXTERN);
catch
  printf("EXTERN is not defined (good)\n");
end
try
  printf("FOO    = %i (Arg! This should not printf(anything)\n", example.FOO);
catch
  printf("FOO is not defined (good)\n");
end

exit
