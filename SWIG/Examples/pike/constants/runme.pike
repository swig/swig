int main()
{
  mixed error;
  
  write(sprintf("ICONST  = %d (should be 42)\n", .example.ICONST));
  write(sprintf("FCONST  = %f (should be 2.1828)\n", .example.FCONST));
  write(sprintf("CCONST  = %c (should be 'x')\n", .example.CCONST));
  write(sprintf("CCONST2 = %c (this should be on a new line)\n", .example.CCONST2));
  write(sprintf("SCONST  = %s (should be 'Hello World')\n", .example.SCONST));
  write(sprintf("SCONST2 = %s (should be '\"Hello World\"')\n", .example.SCONST2));
  write(sprintf("EXPR    = %f (should be 48.5484)\n", .example.EXPR));
  write(sprintf("iconst  = %d (should be 37)\n", .example.iconst));
  write(sprintf("fconst  = %f (should be 3.14)\n", .example.fconst));
  
  /*
  error = catch {
    write(sprintf("EXTERN  = %s (Arg! This shouldn't print anything)\n", .example.EXTERN));
  };
  if (error != 0)
    write("EXTERN isn't defined (good)\n");
  
  error = catch {
    write(sprintf("FOO     = %s (Arg! This shouldn't print anything)\n", .example.FOO));
  };
  if (error != 0)
    write("FOO isn't defined (good)\n");
  */
  
  return 0;
}
