int main()
{
  write(sprintf("ICONST  = %d (should be 42)\n", .example.ICONST));
  write(sprintf("FCONST  = %f (should be 2.1828)\n", .example.FCONST));
  write(sprintf("CCONST  = %c (should be 'x')\n", .example.CCONST));
  write(sprintf("CCONST2 = %c (this should be on a new line)\n", .example.CCONST2));
  write(sprintf("SCONST  = %s (should be 'Hello World')\n", .example.SCONST));
  write(sprintf("SCONST2 = %s (should be '\"Hello World\"')\n", .example.SCONST2));
  write(sprintf("EXPR    = %f (should be 48.5484)\n", .example.EXPR));
  write(sprintf("iconst  = %d (should be 37)\n", .example.iconst));
  write(sprintf("fconst  = %f (should be 3.14)\n", .example.fconst));

  if (search(indices(.example), "EXTERN") == -1)
    write("EXTERN isn't defined (good)\n");
  else
    write("EXTERN is defined (bad)\n");

  if (search(indices(.example), "FOO") == -1)
    write("FOO isn't defined (good)\n");
  else
    write("FOO is defined (bad)\n");

  return 0;
}
