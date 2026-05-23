/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps

   Use it as follows:

     %apply (int ARGC, char **ARGV) { (size_t argc, const char **argv) }

     %inline %{

     int mainApp(size_t argc, const char **argv) {
       return argc;
     }

   then from ruby:

     $args = ["asdf", "asdf2"]
     mainApp(args)

 * ------------------------------------------------------------- */

%typemap(in) (int ARGC, char **ARGV) {
  $1 = 0;
  $2 = NULL;
  if (!rb_obj_is_kind_of($input,rb_cArray)) {
    %argument_fail(SWIG_TypeError, "int ARGC, char **ARGV", $symname, $argnum);
  }
  int i;
  int size = RARRAY_LEN($input);
  $2 = (char **) malloc((size+1)*sizeof(char *));
  if ($2 == NULL) {
    %argument_fail(SWIG_MemoryError, "Failed to allocate memory for 'int ARGC, char **ARGV'", $symname, $argnum);
  }
  $1 = ($1_ltype) size;
  VALUE *ptr = RARRAY_PTR($input);
  for (i = 0; i < size; i++, ptr++) {
    $2[i] = StringValuePtr(*ptr);
  }
  $2[i] = NULL;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  $1 = rb_obj_is_kind_of($input,rb_cArray);
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((char *) $2);
}
