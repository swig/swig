%typemap(ruby,varin) char * "
  Check_Type($source, T_STRING);
  if ($target) free($target);
  $target = xmalloc(RSTRING($source)->len + 1);
  strncpy($target, STR2CSTR($source), RSTRING($source)->len + 1);";
