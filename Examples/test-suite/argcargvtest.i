%module argcargvtest

#if !defined(SWIGC) && !defined(SWIGOCAML)
%include <argcargv.i>

%apply (int ARGC, char **ARGV) { (size_t argc, const char **argv) }
#endif

%inline %{

int mainc(size_t argc, const char **argv) 
{
  return (int)argc;
}

const char* mainv(size_t argc, const char **argv, size_t idx) 
{
  // argv has always size argc+1 and is NULL-terminated
  if (idx <= argc) return argv[idx] ? argv[idx] : "<<NULL>>";
  return "<<OUT OF BOUNDS>>";
}

void initializeApp(size_t argc, const char **argv, bool setPGid = true, bool isMakeline = false)
{
}

%}
