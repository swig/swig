#if defined(SWIGPYTHON_BUILTIN) /* defined when using -builtin */
%module(package="pkg1", moduleimport="from $module import *") foo
#else
%module(package="pkg1", moduleimport="import $module") foo
#endif

%{
static unsigned count(void)
{
  return 3;
}
%}

unsigned count(void);

