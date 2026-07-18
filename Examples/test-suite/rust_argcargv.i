%module rust_argcargv

%include <argcargv.i>

%inline %{
int rust_argcargv_count(int ARGC, char **ARGV) {
  (void)ARGV;
  return ARGC;
}
%}
