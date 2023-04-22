%module argcargvtest

#if !defined(SWIGD) && !defined(SWIGMZSCHEME) && !defined(SWIGOCAML) && !defined(SWIGR)
#define SWIGCSHARP_ARGCARGV_PARAM_IDX "0"
%include <argcargv.i>

#ifndef SWIGCSHARP
%apply (int ARGC, char **ARGV) { (size_t argc, const char **argv) }
#else
%apply (char **ARGV) { const char **argv }
#endif
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
