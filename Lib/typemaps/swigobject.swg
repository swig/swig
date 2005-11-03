/* ------------------------------------------------------------
 * Language Object *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   SWIG_Object "$1 = $input;";
%typemap(freearg) SWIG_Object "";

%typemap(in,noblock=1)   SWIG_Object const & ($*ltype temp)
{
  temp = %static_cast($input, $*ltype);
  $1 = &temp;
}

%typemap(freearg) SWIG_Object const & "";


%typemap(out,noblock=1) SWIG_Object {
  $result = $1;
}

%typemap(out,noblock=1)  SWIG_Object const & {
  $result = *$1;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIG_Object "$1 = ($input != 0);";

%typemap(throws,noblock=1) SWIG_Object {
  %raise($1, "$type", 0);
}

%typemap(constcode,noblock=1) SWIG_Object {
  %set_constant("$symname", $value);
}

#if defined(SWIG_DIRECTOR_TYPEMAPS)

%typemap(directorin) SWIG_Object "$input = $1_name";
%typemap(directorout) SWIG_Object "$result = $input;";

#endif /* SWIG_DIRECTOR_TYPEMAPS */

