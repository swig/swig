%module argcargvtest

%include <argcargv.i>

%apply (int ARGC, char **ARGV) { (size_t argc, const char **argv) }

%inline %{

int mainc(size_t argc, const char **argv) 
{
  return argc;
}

const char* mainv(size_t argc, const char **argv, int idx) 
{
  return argv[idx];
}   


%}
