/* -----------------------------------------------------------------------------
 * argcargv.i
 *
 * Rust typemaps for argc/argv-style argument pairs.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) (int ARGC, char **ARGV) "char **"
%typemap(imtype) (int ARGC, char **ARGV) "*mut *mut c_char"
%typemap(rusttype) (int ARGC, char **ARGV) "*mut *mut c_char"
%typemap(rustin) (int ARGC, char **ARGV) "$rustinput"
%typemap(in) (int ARGC, char **ARGV) %{
  int i = 0;
  if ($input) {
    while ($input[i])
      ++i;
  }
  $1 = i;
  $2 = $input;
%}
