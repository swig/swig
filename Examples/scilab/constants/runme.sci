lines(0);
ilib_verbose(0);
exec loader.sce;
SWIG_Init();

printf("\nConstants are wrapped by functions:\n");
printf("ICONST  = %i (should be 42)\n", ICONST);
printf("FCONST  = %5.4f (should be 2.1828)\n", FCONST);
printf("CCONST  = ''%c'' (should be ''x'')\n", CCONST);
printf("CCONST2 = %s (this should be on a new line)\n", CCONST2);
printf("SCONST  = ''%s'' (should be ''Hello World'')\n", SCONST);
printf("SCONST2 = ''%s'' (should be "'""Hello World"""')\n", SCONST2);
printf("EXPR    = %5.4f (should be 48.5484)\n", EXPR);
printf("iconst  = %i (should be 37)\n", iconst);
printf("fconst  = %3.2f (should be 3.14)\n", fconst);

try
  printf("EXTERN = %s (Arg! This should not printf(anything)\n", EXTERN);
catch
  printf("EXTERN is not defined (good)\n");
end
try
  printf("FOO    = %i (Arg! This should not printf(anything)\n", FOO);
catch
  printf("FOO is not defined (good)\n");
end

exit
