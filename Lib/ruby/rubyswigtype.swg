/* --- Input typemaps --- */

%typemap(in) SWIGTYPE *,
             SWIGTYPE []
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, $disown);"

%typemap(in) SWIGTYPE *DISOWN
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, SWIG_POINTER_DISOWN);"

/* Additional check for null references */
%typemap(in) SWIGTYPE &
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, $disown); if ($1 == NULL) rb_raise(rb_eTypeError, \"null reference\");"

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
   $&1_ltype ptr;
   SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, $disown);
   if (ptr) $1 = *ptr;
}

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) "SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor, $disown);";

/* --- Output typemaps --- */

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,$owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
        swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
        $result = SWIG_NewPointerObj((void *) $1, ty,$owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Primitive types--return by value */
%typemap(out) SWIGTYPE
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &)$1);
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#endif

/* --- Variable Input --- */

%typemap(varin) SWIGTYPE [ANY] {
  void *temp;
  int ii;
  $1_basetype *b = 0;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, 0)) == -1) {
    rb_raise(rb_eTypeError, "C variable '$name ($1_ltype)'");
  }
  b = ($1_basetype *) $1;
  for (ii = 0; ii < $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

%typemap(varin,warning="462: Unable to set dimensionless array variable") SWIGTYPE [] {
  rb_raise(rb_eTypeError, "C/C++ variable '$name' is readonly");
}

/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Ruby class */

%typemap(varin) SWIGTYPE *
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);"

%typemap(varin) SWIGTYPE & {
        void *temp;
        SWIG_ConvertPtr($input, (void **) &temp, $1_descriptor, 1);
        $1 = *($1_ltype) temp;
}

%typemap(varin) SWIGTYPE {
   $&1_ltype ptr;
   SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 1);
   if (ptr) $1 = *ptr;
}

%typemap(varin) SWIGTYPE (CLASS::*) {
    char temp[sizeof($1_type)];
    SWIG_ConvertPacked($input, (void *) temp, sizeof($1_type), $1_descriptor, 1);
    memmove((void *) &$1, temp, sizeof($1_type));
}

/* --- Output typemaps --- */

/* Pointers, references, and arrays */
%typemap(varout) SWIGTYPE*, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,0);";

%typemap(varout) SWIGTYPE &
        "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor,0);";

/* Copy by value */
%typemap(varout) SWIGTYPE "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* --- Constants --- */

%typemap(constant) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "rb_define_const($module,\"$symname\", SWIG_NewPointerObj((void *) $1, $1_descriptor,0));";

%typemap(constant) SWIGTYPE "rb_define_const($module,\"$symname\", SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0));";

%typemap(constant) SWIGTYPE (CLASS::*) "rb_define_const($module, \"$symname\", SWIG_NewPackedObj((void *) &$1, sizeof($type), $1_descriptor));";

/* --- directorin typemaps --- */

/* --- directorout typemaps --- */
%typemap(directorout) SWIGTYPE *,
                      SWIGTYPE &,
                      SWIGTYPE []
       "if ((SWIG_ConvertPtr($input,(void **) &$result, $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 0) != -1)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, $1_descriptor, 0) != -1)) ? 1 : 0;
}

/* ------------------------------------------------------------
 * Exception handling.
 * Note that in Ruby, we can only raise an exception class and
 * not some arbitrary object as in Python.
 * ------------------------------------------------------------ */

%typemap(throws) SWIGTYPE, SWIGTYPE *, SWIGTYPE [ANY], SWIGTYPE &
  "rb_raise(rb_eRuntimeError, \"$1_type\");";

