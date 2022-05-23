%module argcargvtest

#if !defined(SWIGCSHARP) && !defined(SWIGD) && !defined(SWIGGO) && !defined(SWIGGUILE) && !defined(SWIGJAVA) && !defined(SWIGJAVASCRIPT) && !defined(SWIGMZSCHEME) && !defined(SWIGOCAML) && !defined(SWIGR) && !defined(SWIGSCILAB)
%include <argcargv.i>

%apply (int ARGC, char **ARGV) { (size_t argc, const char **argv) }
#endif

%inline %{

int mainc(size_t argc, const char **argv) 
{
  return (int)argc;
}

const char* mainv(size_t argc, const char **argv, int idx) 
{
  return argv[idx];
}   

void initializeApp(size_t argc, const char **argv, bool setPGid = true, bool isMakeline = false)
{
}

%}
