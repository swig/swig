/* ------------------------------------------------------------
 * VALUE  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

typedef unsigned long VALUE;

%typemap(in)  VALUE "$1 = $input;";
%typemap(out) VALUE "$result = $1;";

%typemap(directorin) VALUE  "$input = $1;";
%typemap(directorout) VALUE "$result = $input;";

%typecheck(SWIG_TYPECHECK_POINTER) VALUE "$1 = ($input != T_NONE);";
