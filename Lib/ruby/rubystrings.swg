/* --- Input Values --- */

%typemap(in) char *          "$1 = StringValuePtr($input);";
%typemap(in) char [ANY]      "$1 = StringValuePtr($input);";

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (int LENGTH, char *STRING) {
    $1 = ($1_ltype) StringValueLen($input);
    $2 = ($2_ltype) StringValuePtr($input);
}

%typemap(in) (char *STRING, int LENGTH) {
    $1 = ($1_ltype) StringValuePtr($input);
    $2 = ($2_ltype) StringValueLen($input);
}

/* --- Output typemaps --- */

/* Single char */
%typemap(out) char         "$result = rb_str_new(&$1,1);";
%typemap(out) const char & "$result = rb_str_new($1, 1);";

/* C string */
%typemap(out) char * "$result = rb_str_new2($1);";

/* Special typemap for character array return values */
%typemap(out) char [ANY], const char [ANY] "$result = rb_str_new2($1);";

/* --- Variable Input --- */

/* A string */
#ifdef __cplusplus

%typemap(varin) char * {
  char *temp = (char *) StringValuePtr($input);
  if ($1) delete [] $1;
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) StringValuePtr($input);
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}

#else

%typemap(varin) char * {
  char *temp = (char *) StringValuePtr($input);
  if ($1) free((char*) $1);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) StringValuePtr($input);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}

#endif /* __cplusplus */

/* Special case for string array variables */
%typemap(varin,
         warning="462:Unable to set variable of type char []") char[]
{
  rb_raise(rb_eTypeError, "C/C++ variable '$name' is read-only.");
}

%typemap(varin) char[ANY] "strncpy($1,StringValuePtr($input),$1_dim0);";

/* --- Variable Output --- */

/* Character */
%typemap(varout) char "$result = rb_str_new(&$1,1);";

/* C string */
%typemap(varout) char * "$result = rb_str_new2($1);";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] "$result = rb_str_new2($1);";

/* --- Constants --- */

%typemap(constant) char {
  char temp = $1;
  rb_define_const($module,"$symname", rb_str_new(&temp,1));
}

%typemap(constant) char *
        "rb_define_const($module,\"$symname\", rb_str_new2($1));";

/* directorin typemaps */

%typemap(directorin) char * "$input = rb_str_new2($1);";

/* directorout typemaps */

%typemap(directorout) char *       "$result = STR2CSTR($1);";
%typemap(directorout) const char * "$result = STR2CSTR($1);";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = (TYPE($input) == T_STRING && (RSTRING($input)->len == 1)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = (TYPE($input) == T_STRING) ? 1 : 0;
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

%typemap(throws) char * {
  rb_raise(rb_eRuntimeError, $1);
}

