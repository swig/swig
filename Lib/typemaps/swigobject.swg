/* ------------------------------------------------------------
 * Language Object *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%check_swig_object()

%typemap(in)   SWIG_Object "$1 = $input;";

%typemap(out,noblock=1)  SWIG_Object {
  SWIG_set_result($1);
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIG_Object "$1 = ($input != 0);";

%typemap(throws,noblock=1) SWIG_Object {
  SWIG_raise($1, "$type", 0);
}

%typemap(constcode,noblock=1) SWIG_Object {
  SWIG_set_constant("$symname", $value);
}

#ifdef SWIG_DIRECTOR_TYPEMAPS

%typemap(directorin) SWIG_Object "$input = $1_name";
%typemap(directorout) SWIG_Object "$result = $input;";

#endif /* SWIG_DIRECTOR_TYPEMAPS */

